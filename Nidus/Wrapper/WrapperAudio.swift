import AVFoundation
import OSLog
import Speech

enum AudioError: Error {
	case noMicrophonePermission
	case noSpeechPermission
}

class WrapperAudio: NSObject {
	var hasMicrophonePermission = false
	var hasTranscriptionPermission = false

	private var audioRecorder: AVAudioRecorder?
	private var audioPlayer: AVAudioPlayer?
	private var onTranscriptionCallbacks: [(String) -> Void] = []
	private var speechRecognizer: SFSpeechRecognizer?
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask: SFSpeechRecognitionTask?
	private var audioEngine = AVAudioEngine()
	private var hasSpeechPermission = false

	override init() {
		super.init()
		speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
	}

	func onTranscriptionUpdate(_ callback: @escaping (String) -> Void) {
		onTranscriptionCallbacks.append(callback)
	}

	private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
		if #available(iOS 17.0, *) {
			AVAudioApplication.requestRecordPermission { granted in
				completion(granted)
			}
		}
		else {
			AVAudioSession.sharedInstance().requestRecordPermission { granted in
				completion(granted)
			}
		}
	}

	private func requestTranscriptionPermission(completion: @escaping (Bool) -> Void) {
		SFSpeechRecognizer.requestAuthorization { authStatus in
			completion(authStatus == .authorized)
		}
	}

	func requestPermissions(_ onPermission: @escaping (Bool, Bool) -> Void) {
		let group = DispatchGroup()

		group.enter()
		requestMicrophonePermission { granted in
			self.hasMicrophonePermission = granted
			group.leave()
		}

		group.enter()
		requestTranscriptionPermission { granted in
			self.hasSpeechPermission = granted
			group.leave()
		}

		group.notify(queue: .main) {
			onPermission(self.hasMicrophonePermission, self.hasSpeechPermission)
		}
	}

	func startRecording(_ uuid: UUID) throws {
		guard hasMicrophonePermission else {
			throw AudioError.noMicrophonePermission
		}

		// Start audio recording
		startAudioRecording(uuid)

		// Start speech recognition
		startSpeechRecognition()

	}

	func stopRecording() {
		// Stop audio recording
		audioRecorder?.stop()

		// Stop speech recognition
		audioEngine.stop()
		audioEngine.inputNode.removeTap(onBus: 0)
		recognitionRequest?.endAudio()
		recognitionRequest = nil
		recognitionTask?.cancel()
		recognitionTask = nil
	}

	func playRecording(url: URL) {
		do {
			audioPlayer = try AVAudioPlayer(contentsOf: url)
			audioPlayer?.play()
		}
		catch {
			print("Failed to play recording: \(error)")
		}
	}

	private func handleTranscriptionUpdate(_ transcription: String) {
		for c in onTranscriptionCallbacks {
			c(transcription)
		}
	}

	private func startAudioRecording(_ uuid: UUID) {
		let audioSession = AVAudioSession.sharedInstance()

		do {
			try audioSession.setCategory(.record, mode: .default)
			try audioSession.setActive(true)

			let audioFilename = AudioNote.url(uuid)

			let settings = [
				AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
				AVSampleRateKey: 12000,
				AVNumberOfChannelsKey: 1,
				AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
			]

			audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
			audioRecorder?.delegate = self
			audioRecorder?.record()
			Logger.foreground.info("Started recording audio to \(audioFilename)")
		}
		catch {
			Logger.foreground.info("Failed to start audio recording: \(error)")
		}
	}

	private func startSpeechRecognition() {
		Logger.foreground.info("Starting speech recognition")
		guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
			Logger.foreground.info("Speech recognizer not available")
			return
		}
		handleTranscriptionUpdate("")

		// Cancel any previous task
		recognitionTask?.cancel()
		recognitionTask = nil

		let audioSession = AVAudioSession.sharedInstance()

		do {
			try audioSession.setCategory(
				.record,
				mode: .measurement,
				options: .duckOthers
			)
			try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

			recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
			recognitionRequest!.taskHint = .dictation
			recognitionRequest!.contextualStrings = [
				"Aedes",
				"Aegypti",
				"instar",
				"larvae",
				"Culex",
				"Quinks",
				"Sumilarv",
				"WSP",
				"flood irrigating",
			]
			if let languageModelUrl = Bundle.main.url(
				forResource: "NidusSpeechModel",
				withExtension: "bin"
			) {
				let lmConfiguration: SFSpeechLanguageModel.Configuration =
					SFSpeechLanguageModel.Configuration(
						languageModel: languageModelUrl
					)
				recognitionRequest!.customizedLanguageModel = lmConfiguration
				Logger.foreground.info("Loaded custom speech module")
			}
			else {
				Logger.foreground.warning("Failed to load custom speech model")
			}
			guard let recognitionRequest = recognitionRequest else {
				print("Unable to create recognition request")
				return
			}

			recognitionRequest.shouldReportPartialResults = true

			let inputNode = audioEngine.inputNode

			recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest)
			{ result, error in
				DispatchQueue.main.async {
					if let result = result {
						self.handleTranscriptionUpdate(
							result.bestTranscription.formattedString
						)
					}

					if error != nil {
						self.audioEngine.stop()
						inputNode.removeTap(onBus: 0)
						self.recognitionRequest = nil
						self.recognitionTask = nil
					}
				}
			}

			let recordingFormat = inputNode.outputFormat(forBus: 0)
			inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
				buffer,
				_ in
				self.recognitionRequest?.append(buffer)
			}

			audioEngine.prepare()
			try audioEngine.start()
			Logger.foreground.info("Speech recognition started")
		}
		catch {
			print("Failed to start speech recognition: \(error)")
		}
	}

}

extension WrapperAudio: AVAudioRecorderDelegate {
	func audioRecorderDidFinishRecording(
		_ recorder: AVAudioRecorder,
		successfully success: Bool
	) {
		if success {
			Logger.background.info("Audio recording completed successfully")
		}
	}
}

class AudioRecorderFake: WrapperAudio {
	init(
		hasPermissions: Bool = true,
		isRecording: Bool = false
	) {
		super.init()
	}

}
