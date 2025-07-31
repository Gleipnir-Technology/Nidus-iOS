import AVFoundation
import OSLog
import Speech

class WrapperAudio: NSObject {
	var hasPermissions = false
	var isRecording: Bool = false
	var recordingDuration: TimeInterval = 0
	var recordingTranscription: String?
	var recordingUUID: UUID = UUID()

	private var audioRecorder: AVAudioRecorder?
	private var audioPlayer: AVAudioPlayer?
	private var onPermissionCallbacks: [(Bool) -> Void] = []
	private var timer: Timer?
	private var speechRecognizer: SFSpeechRecognizer?
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask: SFSpeechRecognitionTask?
	private var audioEngine = AVAudioEngine()
	private var hasMicrophonePermission = false
	private var hasSpeechPermission = false

	var onRecordingStop: ((AudioRecording) -> Void) = { _ in }

	override init() {
		super.init()
		speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
	}

	func requestPermissions(_ onPermission: @escaping (Bool) -> Void) {
		onPermissionCallbacks.append(onPermission)
		// Request microphone permission
		if #available(iOS 17.0, *) {
			AVAudioApplication.requestRecordPermission { granted in
				DispatchQueue.main.async {
					self.hasMicrophonePermission = granted
					while self.onPermissionCallbacks.count > 0 {
						if let callback = self.onPermissionCallbacks
							.popLast()
						{
							callback(granted)
						}
					}
				}
			}
		}
		else {
			AVAudioSession.sharedInstance().requestRecordPermission { granted in
				DispatchQueue.main.async {
					self.hasMicrophonePermission = granted
					while self.onPermissionCallbacks.count > 0 {
						if let callback = self.onPermissionCallbacks
							.popLast()
						{
							callback(granted)
						}
					}
				}
			}
		}

		// Request speech recognition permission
		SFSpeechRecognizer.requestAuthorization { authStatus in
			DispatchQueue.main.async {
				self.hasSpeechPermission = authStatus == .authorized
			}
		}
	}

	func startRecording() {
		guard hasPermissions else {
			Logger.foreground.warning("Can't start recording, missing permissions")
			return
		}

		recordingDuration = 0

		// Start audio recording
		startAudioRecording()

		// Start speech recognition
		startSpeechRecognition()

		isRecording = true

		// Start timer for recording duration
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
			self.recordingDuration += 1
		}
	}

	private func startAudioRecording() {
		let audioSession = AVAudioSession.sharedInstance()

		do {
			try audioSession.setCategory(.record, mode: .default)
			try audioSession.setActive(true)

			let audioFilename = AudioRecording.url(recordingUUID)

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
		guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
			Logger.foreground.info("Speech recognizer not available")
			recordingTranscription = nil
			return
		}
		recordingTranscription = ""

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
						self.recordingTranscription =
							result.bestTranscription.formattedString
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

		}
		catch {
			print("Failed to start speech recognition: \(error)")
		}
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

		timer?.invalidate()
		timer = nil
		isRecording = false
		let recording = AudioRecording(
			created: Date.now,
			duration: recordingDuration,
			transcription: recordingTranscription,
			uuid: recordingUUID
		)
		recordingUUID = UUID()

		onRecordingStop(recording)
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
		isRecording: Bool = false,
		recordingDuration: TimeInterval = TimeInterval(integerLiteral: 123),
		transcribedText: String = ""
	) {
		super.init()
		self.hasPermissions = hasPermissions
		self.isRecording = isRecording
		self.recordingDuration = recordingDuration
		self.recordingTranscription = transcribedText
	}

}
