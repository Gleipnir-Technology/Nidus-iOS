//
//  AudioRecorderView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/25/25.
//

import AVFoundation
import CoreLocation
import Speech
import SwiftUI

struct AudioStatusView: View {
	var audioRecorder: AudioRecorder
	private func formatTime(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
	var body: some View {
		HStack {
			// Record button
			Button(action: {
				if audioRecorder.isRecording {
					audioRecorder.stopRecording()
				}
				else {
					audioRecorder.startRecording()
				}
			}) {
				Image(
					systemName: audioRecorder.isRecording
						? "stop.circle.fill" : "mic.circle.fill"
				)
				.font(.system(size: 80))
				.foregroundColor(audioRecorder.isRecording ? .red : .blue)
			}
			.disabled(!audioRecorder.hasPermissions)

			// Permission status
			if audioRecorder.hasPermissions {
				// Recording status
				Text(audioRecorder.isRecording ? "Recording..." : "Ready to record")
					.font(.headline)
					.foregroundColor(
						audioRecorder.isRecording ? .red : .primary
					)
			}
			else {
				VStack {
					Text("Permissions required:")
						.font(.caption)
						.foregroundColor(.red)
					Text("• Microphone access")
						.font(.caption2)
						.foregroundColor(.red)
					Text("• Speech recognition")
						.font(.caption2)
						.foregroundColor(.red)
				}
			}

			// Recording duration
			if audioRecorder.isRecording {
				Text("Duration: \(formatTime(audioRecorder.recordingTime))")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
	}
}
struct AudioRecorderView: View {
	@State private var audioRecorder: AudioRecorder

	init(audioRecorder: AudioRecorder) {
		self._audioRecorder = .init(wrappedValue: audioRecorder)
	}

	init() {
		self.init(audioRecorder: AudioRecorder())
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			AudioStatusView(audioRecorder: audioRecorder)

			// Live transcription
			if audioRecorder.isRecording
				&& !audioRecorder.transcribedText.isEmpty
			{
				ScrollView {
					Text(audioRecorder.transcribedText)
						.padding()
						.frame(
							maxWidth: .infinity,
							alignment: .leading
						)
						.background(Color.blue.opacity(0.1))
						.cornerRadius(10)
				}
				.frame(maxHeight: 150)
			}

			// Recordings list
			if !audioRecorder.recordings.isEmpty {
				VStack(alignment: .leading, spacing: 10) {
					Text("Recordings")
						.font(.headline)

					ForEach(audioRecorder.recordings, id: \.self) {
						recording in
						HStack {
							VStack(alignment: .leading) {
								Text(
									recording
										.lastPathComponent
								)
								.font(.caption)
								if let transcription =
									audioRecorder
									.savedTranscriptions[
										recording
											.lastPathComponent
									]
								{
									Text(
										transcription
											.prefix(
												50
											)
											+ (transcription
												.count
												> 50
												? "..."
												: "")
									)
									.font(.caption2)
									.foregroundColor(
										.secondary
									)
								}
							}
							Spacer()
							Button("Play") {
								audioRecorder.playRecording(
									url: recording
								)
							}
							.font(.caption)
						}
						.padding(.horizontal)
					}
				}
				.padding()
				.background(Color.gray.opacity(0.1))
				.cornerRadius(10)
			}
		}
		.padding()
		.onAppear {
			audioRecorder.requestPermissions()
		}
	}

}

class AudioRecorder: NSObject, ObservableObject {
	@Published var isRecording = false
	@Published var hasPermissions = false
	@Published var recordings: [URL] = []
	@Published var recordingTime: TimeInterval = 0
	@Published var transcribedText = ""
	@Published var savedTranscriptions: [String: String] = [:]

	private var audioRecorder: AVAudioRecorder?
	private var audioPlayer: AVAudioPlayer?
	private var timer: Timer?
	private var speechRecognizer: SFSpeechRecognizer?
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask: SFSpeechRecognitionTask?
	private var audioEngine = AVAudioEngine()
	private var hasMicrophonePermission = false
	private var hasSpeechPermission = false

	override init() {
		super.init()
		speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
		loadRecordings()
		loadTranscriptions()
	}

	func requestPermissions() {
		// Request microphone permission
		if #available(iOS 17.0, *) {
			AVAudioApplication.requestRecordPermission { granted in
				DispatchQueue.main.async {
					self.hasMicrophonePermission = granted
					self.updatePermissionStatus()
				}
			}
		}
		else {
			AVAudioSession.sharedInstance().requestRecordPermission { granted in
				DispatchQueue.main.async {
					self.hasMicrophonePermission = granted
					self.updatePermissionStatus()
				}
			}
		}

		// Request speech recognition permission
		SFSpeechRecognizer.requestAuthorization { authStatus in
			DispatchQueue.main.async {
				self.hasSpeechPermission = authStatus == .authorized
				self.updatePermissionStatus()
			}
		}
	}

	private func updatePermissionStatus() {
		hasPermissions = hasMicrophonePermission && hasSpeechPermission
	}

	func startRecording() {
		guard hasPermissions else { return }

		// Start audio recording
		startAudioRecording()

		// Start speech recognition
		startSpeechRecognition()

		isRecording = true
		recordingTime = 0
		transcribedText = ""

		// Start timer for recording duration
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
			self.recordingTime += 1
		}
	}

	private func startAudioRecording() {
		let audioSession = AVAudioSession.sharedInstance()

		do {
			try audioSession.setCategory(.playAndRecord, mode: .default)
			try audioSession.setActive(true)

			let documentsPath = FileManager.default.urls(
				for: .documentDirectory,
				in: .userDomainMask
			)[0]
			let audioFilename = documentsPath.appendingPathComponent(
				"recording_\(Date().timeIntervalSince1970).m4a"
			)

			let settings = [
				AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
				AVSampleRateKey: 12000,
				AVNumberOfChannelsKey: 1,
				AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
			]

			audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
			audioRecorder?.delegate = self
			audioRecorder?.record()

		}
		catch {
			print("Failed to start audio recording: \(error)")
		}
	}

	private func startSpeechRecognition() {
		guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
			print("Speech recognizer not available")
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
						self.transcribedText =
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
		recordingTime = 0

		// Save transcription
		if let audioRecorder = audioRecorder, !transcribedText.isEmpty {
			let filename = audioRecorder.url.lastPathComponent
			savedTranscriptions[filename] = transcribedText
			saveTranscriptions()
		}

		loadRecordings()
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

	private func loadRecordings() {
		let documentsPath = FileManager.default.urls(
			for: .documentDirectory,
			in: .userDomainMask
		)[0]

		do {
			let files = try FileManager.default.contentsOfDirectory(
				at: documentsPath,
				includingPropertiesForKeys: nil
			)
			recordings = files.filter { $0.pathExtension == "m4a" }
		}
		catch {
			print("Failed to load recordings: \(error)")
		}
	}

	private func saveTranscriptions() {
		let documentsPath = FileManager.default.urls(
			for: .documentDirectory,
			in: .userDomainMask
		)[0]
		let transcriptionsURL = documentsPath.appendingPathComponent("transcriptions.json")

		do {
			let data = try JSONEncoder().encode(savedTranscriptions)
			try data.write(to: transcriptionsURL)
		}
		catch {
			print("Failed to save transcriptions: \(error)")
		}
	}

	private func loadTranscriptions() {
		let documentsPath = FileManager.default.urls(
			for: .documentDirectory,
			in: .userDomainMask
		)[0]
		let transcriptionsURL = documentsPath.appendingPathComponent("transcriptions.json")

		do {
			let data = try Data(contentsOf: transcriptionsURL)
			savedTranscriptions = try JSONDecoder().decode(
				[String: String].self,
				from: data
			)
		}
		catch {
			// File doesn't exist or couldn't be loaded, start with empty dictionary
			savedTranscriptions = [:]
		}
	}
}

extension AudioRecorder: AVAudioRecorderDelegate {
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if flag {
			loadRecordings()
		}
	}
}

class AudioRecorderFake: AudioRecorder {

	init(hasPermissions: Bool) {
		super.init()
		self.hasPermissions = hasPermissions
	}

	override func requestPermissions() {
	}
}
// MARK: - Preview
struct AudioRecorder_Previews: PreviewProvider {
	static var previews: some View {
		AudioRecorderView(audioRecorder: AudioRecorderFake(hasPermissions: false))
			.previewDisplayName("No Permissions")
		AudioRecorderView(audioRecorder: AudioRecorderFake(hasPermissions: true))
	}
}
