import AVFoundation
import OSLog
import Speech

enum AudioError: Error {
	case noMicrophonePermission
	case noSpeechPermission
}

let PAUSE_THRESHOLD_SECONDS: Double = 1.75

class WrapperAudio: NSObject {
	var hasMicrophonePermission = false
	var hasTranscriptionPermission = false

	private var audioEngine = AVAudioEngine()
	private var audioRecorder: AVAudioRecorder?
	private var audioPlayer: AVAudioPlayer?
	private var clock: ContinuousClock
	private var hasSpeechPermission = false
	private var lastTranscriptionUpdateTime: ContinuousClock.Instant
	private var onTranscriptionCallbacks: [(String) -> Void] = []
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask: SFSpeechRecognitionTask?
	private var speechRecognizer: SFSpeechRecognizer
	private var transcriptions: [SFTranscription] = []

	override init() {
		self.clock = ContinuousClock()
		self.lastTranscriptionUpdateTime = self.clock.now
		self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
		super.init()
	}

	func onAppear() {
		Task.detached {
			do {
				if let languageModelUrl = Bundle.main.url(
					forResource: "NidusSpeechModel",
					withExtension: "bin"
				) {
					try await SFSpeechLanguageModel.prepareCustomLanguageModel(
						for: languageModelUrl,
						clientIdentifier: "technology.gleipnir.apps.nidus",
						configuration: self.lmConfiguration
					)
					Logger.background.info("Loaded custom speech module")
				}
				else {
					Logger.background.warning(
						"Failed to load custom speech model"
					)
				}
			}
			catch {
				Logger.background.warning(
					"Failed to prepare custom LM: \(error.localizedDescription)"
				)
			}
		}
	}

	private var lmConfiguration: SFSpeechLanguageModel.Configuration {
		let outputDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
			.first!
		let dynamicLanguageModel = outputDir.appendingPathComponent("LM")
		let dynamicVocabulary = outputDir.appendingPathComponent("Vocab")
		return SFSpeechLanguageModel.Configuration(
			languageModel: dynamicLanguageModel,
			vocabulary: dynamicVocabulary
		)
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

	private func handleTranscriptionUpdate(_ newTranscription: SFTranscription) {
		//let words = newTranscription.formattedString.components(separatedBy: .whitespaces)
		let utterances = newTranscription.segments.map { segment in
			"\(segment.substring) (\(segment.confidence))"
		}.joined(separator: " ")
		let elapsed = self.lastTranscriptionUpdateTime.duration(to: clock.now)
		let elapsedSeconds: Double =
			Double(elapsed.components.seconds)
			+ (Double(elapsed.components.attoseconds) / 1_000_000_000_000_000_000)
		//let hasConfidence = newTranscription.segments.contains(where: { $0.confidence > 0.01 })
		Logger.foreground.info(
			"Speech: \(elapsedSeconds) - \(utterances)"
		)

		self.lastTranscriptionUpdateTime = clock.now
		// If we have no transcriptions at all, just take whatever they give you
		if transcriptions.last == nil {
			transcriptions = [newTranscription]
		}
		// If we have transcriptions, but the latest one has no confidence, replace it
		else if transcriptions.last!.segments.reduce(0.0, { $0 + $1.confidence }) == 0.0 {
			transcriptions[transcriptions.count - 1] = newTranscription
			// If our last transcription has confidence, add a new transcription
		}
		else {
			transcriptions.append(newTranscription)
			Logger.foreground.info(
				"Started new utterance since our last is confident"
			)
		}
		let transcript: String = transcriptions.reduce("") { collector, current in
			if collector.isEmpty {
				return current.formattedString
			}
			else {
				return collector + ". " + current.formattedString
			}
		}
		for c in onTranscriptionCallbacks {
			c(transcript)
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
		if !speechRecognizer.isAvailable {
			Logger.foreground.info("Speech recognizer not available")
			return
		}

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

			self.lastTranscriptionUpdateTime = self.clock.now
			self.transcriptions = []
			recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
			guard let recognitionRequest = recognitionRequest else {
				fatalError(
					"Unable to created a SFSpeechAudioBufferRecognitionRequest object"
				)
			}
			recognitionRequest.shouldReportPartialResults = true
			recognitionRequest.requiresOnDeviceRecognition = true
			recognitionRequest.customizedLanguageModel = self.lmConfiguration

			recognitionRequest.taskHint = .dictation
			recognitionRequest.contextualStrings = [
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
			let inputNode = audioEngine.inputNode

			recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest)
			{ result, error in
				DispatchQueue.main.async {
					if let result = result {
						if result.isFinal {
							Logger.foreground.info(
								"Speech recognition complete"
							)
						}
						self.handleTranscriptionUpdate(
							result.bestTranscription
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
