import AVFoundation
//
//  AddNoteView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/25/25.
//
import SwiftUI

struct VoiceRecorderView: View {
	@StateObject private var audioRecorder = AudioRecorder()

	var body: some View {
		VStack(spacing: 30) {
			Text("Voice Memo Recorder")
				.font(.title)
				.fontWeight(.bold)

			// Recording status
			Text(audioRecorder.isRecording ? "Recording..." : "Ready to record")
				.font(.headline)
				.foregroundColor(audioRecorder.isRecording ? .red : .primary)

			// Recording duration
			if audioRecorder.isRecording {
				Text("Duration: \(formatTime(audioRecorder.recordingTime))")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}

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
			.disabled(!audioRecorder.hasPermission)

			// Permission status
			if !audioRecorder.hasPermission {
				Text("Microphone permission required")
					.font(.caption)
					.foregroundColor(.red)
			}

			// Recordings list
			if !audioRecorder.recordings.isEmpty {
				VStack(alignment: .leading, spacing: 10) {
					Text("Recordings")
						.font(.headline)

					ForEach(audioRecorder.recordings, id: \.self) { recording in
						HStack {
							Text(recording.lastPathComponent)
								.font(.caption)
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
			audioRecorder.requestPermission()
		}
	}

	private func formatTime(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}

class AudioRecorder: NSObject, ObservableObject {
	@Published var isRecording = false
	@Published var hasPermission = false
	@Published var recordings: [URL] = []
	@Published var recordingTime: TimeInterval = 0

	private var audioRecorder: AVAudioRecorder?
	private var audioPlayer: AVAudioPlayer?
	private var timer: Timer?

	override init() {
		super.init()
		loadRecordings()
	}

	func requestPermission() {
		if #available(iOS 17.0, *) {
			AVAudioApplication.requestRecordPermission { granted in
				DispatchQueue.main.async {
					self.hasPermission = granted
				}
			}
		}
		else {
			// Fallback for iOS versions prior to 17.0
			AVAudioSession.sharedInstance().requestRecordPermission { granted in
				DispatchQueue.main.async {
					self.hasPermission = granted
				}
			}
		}
	}

	func startRecording() {
		guard hasPermission else { return }

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

			isRecording = true
			recordingTime = 0

			// Start timer for recording duration
			timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
				self.recordingTime += 1
			}

		}
		catch {
			print("Failed to start recording: \(error)")
		}
	}

	func stopRecording() {
		audioRecorder?.stop()
		timer?.invalidate()
		timer = nil
		isRecording = false
		recordingTime = 0
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
}

extension AudioRecorder: AVAudioRecorderDelegate {
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if flag {
			loadRecordings()
		}
	}
}
