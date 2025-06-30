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
	var recordings: [AudioRecording] = []

	var recordingTime: Double {
		return recordings.reduce(
			0.0,
			{ accumulator, next in
				accumulator + next.duration
			}
		)
	}
	var recordingList: some View {
		HStack {
			VStack(alignment: .leading, spacing: 10) {
				Text("\(recordings.count) recording(s)")
				Text(verbatim: .init(format: "%.2f seconds", recordingTime))
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
	var transcription: String?

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
			if transcription == nil {
				Text("Transcription disabled")
			}
			else {
				ScrollViewReader { proxy in
					ScrollView {
						Text(transcription!)
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
	@Binding var isShowingEditSheet: Bool
	@Binding var recordings: [AudioRecording]

	var editButton: some View {
		Button(action: onPickerButton) {
			Image(systemName: "square.and.pencil")
				.font(.system(size: 80))
				.foregroundColor(.blue)
		}.buttonStyle(BorderlessButtonStyle())
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
		.buttonStyle(BorderlessButtonStyle())
		.disabled(!audioRecorder.hasPermissions)
	}
	func onPickerButton() {
		isShowingEditSheet = true
	}

	var body: some View {
		HStack(spacing: 8) {
			recordButton
			if audioRecorder.isRecording {
				AudioStatusRecordingView(
					hasPermissions: audioRecorder.hasPermissions,
					recordingTime: audioRecorder.recordingDuration,
					transcription: audioRecorder.recordingTranscription
				)
			}
			else {
				AudioStatusIdleView(
					playRecording: audioRecorder.playRecording,
					recordings: recordings
				)
			}
			Spacer()
			if !recordings.isEmpty {
				editButton
			}
		}
		.frame(height: 130)
		.onAppear {
			audioRecorder.requestPermissions()
		}
	}

}

// MARK: - Preview
struct AudioRecorder_Previews: PreviewProvider {
	@State static var isShowingEditSheet: Bool = false
	@State static var recordings: [AudioRecording] = [
		AudioRecording(
			created: Date.now.addingTimeInterval(-100),
			duration: TimeInterval(integerLiteral: 10)
		),
		AudioRecording(
			created: Date.now.addingTimeInterval(-90),
			duration: TimeInterval(integerLiteral: 10)
		),
		AudioRecording(
			created: Date.now.addingTimeInterval(-80),
			duration: TimeInterval(integerLiteral: 10)
		),
		AudioRecording(
			created: Date.now.addingTimeInterval(-70),
			duration: TimeInterval(integerLiteral: 10)
		),
		AudioRecording(
			created: Date.now.addingTimeInterval(-60),
			duration: TimeInterval(integerLiteral: 10)
		),
		AudioRecording(
			created: Date.now.addingTimeInterval(-50),
			duration: TimeInterval(integerLiteral: 10)
		),
		AudioRecording(
			created: Date.now.addingTimeInterval(-40),
			duration: TimeInterval(integerLiteral: 10)
		),
	]
	static var previews: some View {
		AudioRecorderView(
			audioRecorder: AudioRecorderFake(hasPermissions: false),
			isShowingEditSheet: $isShowingEditSheet,
			recordings: $recordings
		).previewDisplayName("No Permissions")
		AudioRecorderView(
			audioRecorder: AudioRecorderFake(isRecording: false),
			isShowingEditSheet: $isShowingEditSheet,
			recordings: $recordings
		).previewDisplayName("Before Recording")
		AudioRecorderView(
			audioRecorder: AudioRecorderFake(
				isRecording: false
			),
			isShowingEditSheet: $isShowingEditSheet,
			recordings: $recordings
		).background(.pink).previewDisplayName("With recordings")
		AudioRecorderView(
			audioRecorder: AudioRecorderFake(
				isRecording: true,
				recordingDuration: TimeInterval(integerLiteral: 98),
				transcribedText:
					"This is a bunch of stuff that I've just said that is all over this place. Let's assume that I've just filled this with tons and tons of words so that we can see what happens when we overflow the limits of the view."
			),
			isShowingEditSheet: $isShowingEditSheet,
			recordings: $recordings
		).background(.green).previewDisplayName("Is Recording")
	}
}
