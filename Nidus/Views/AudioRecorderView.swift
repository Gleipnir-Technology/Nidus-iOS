//
//  AudioRecorderView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/25/25.
//

import CoreLocation
import OSLog
import SwiftUI

struct AudioStatusIdleView: View {
	var playRecording: (URL) -> Void
	var recordings: [URL] = []

	var recordingList: some View {
		VStack(alignment: .leading, spacing: 10) {
			ForEach(recordings, id: \.self) { recording in
				HStack {
					Text(recording.lastPathComponent)
						.font(.caption)
					Spacer()
					Button("Play") {
						playRecording(recording)
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

	var body: some View {
		VStack(alignment: .leading) {
			Text("Ready to record")
				.font(.headline)
				.foregroundColor(
					.primary
				)
			if !recordings.isEmpty {
				recordingList
			}
		}
	}
}

struct AudioStatusRecordingView: View {
	var hasPermissions: Bool
	var recordingTime: TimeInterval
	var transcription: String

	private func formatTime(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}

	var needsPermissionText: some View {
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

	var statusText: some View {
		VStack(alignment: .leading) {
			// Recording status
			Text(
				"Recording..."
			)
			.font(.headline)
			.foregroundColor(
				.red
			)
			// Recording duration
			Text("Duration: \(formatTime(recordingTime))")
				.font(.subheadline)
				.foregroundColor(.secondary)
			if !transcription.isEmpty {
				ScrollViewReader { proxy in
					ScrollView {
						Text(transcription)
							.frame(
								maxWidth: .infinity,
								alignment: .leading
							)
							.background(
								Color.cyan.opacity(
									0.1
								)
							)
							.font(.caption)
							.id("transcription")
					}.onChange(of: transcription) {
						withAnimation(
							.easeInOut(duration: 0.3)
						) {
							proxy.scrollTo(
								"transcription",
								anchor: .bottom
							)
						}
					}.frame(maxHeight: 100)
				}
			}
		}
	}

	var body: some View {
		HStack {
			if hasPermissions {
				statusText
			}
			else {
				needsPermissionText
			}
		}
	}
}
struct AudioRecorderView: View {
	var audioRecorder: AudioRecorder
	init(_ a: AudioRecorder) {
		self.audioRecorder = a
	}

	var recordButton: some View {
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
	}

	var body: some View {
		HStack(spacing: 8) {
			recordButton
			if audioRecorder.isRecording {
				AudioStatusRecordingView(
					hasPermissions: audioRecorder.hasPermissions,
					recordingTime: audioRecorder.recordingTime,
					transcription: audioRecorder.transcribedText
				)
			}
			else {
				AudioStatusIdleView(
					playRecording: audioRecorder.playRecording,
					recordings: audioRecorder.recordings
				)
			}
			Spacer()
		}
		.frame(height: 130)
		.onAppear {
			audioRecorder.requestPermissions()
		}
	}

}

// MARK: - Preview
struct AudioRecorder_Previews: PreviewProvider {
	static var previews: some View {
		AudioRecorderView(
			AudioRecorderFake(hasPermissions: false)
		).previewDisplayName("No Permissions")
		AudioRecorderView(
			AudioRecorderFake(isRecording: false)
		).previewDisplayName("Before Recording")
		AudioRecorderView(
			AudioRecorderFake(
				isRecording: false,
				recordings: [
					URL(string: "file:///one.m4a")!,
					URL(string: "file:///two.m4a")!,
					URL(string: "file:///three.m4a")!,
					URL(string: "file:///four.m4a")!,
					URL(string: "file:///five.m4a")!,
					URL(string: "file:///six.m4a")!,
					URL(string: "file:///seven.m4a")!,
				]
			)
		).previewDisplayName("With recordings")
		AudioRecorderView(
			AudioRecorderFake(
				isRecording: true,
				recordingDuration: TimeInterval(integerLiteral: 98),
				transcribedText:
					"This is a bunch of stuff that I've just said that is all over this place. Let's assume that I've just filled this with tons and tons of words so that we can see what happens when we overflow the limits of the view."
			)
		).background(.green).previewDisplayName("Is Recording")
	}
}
