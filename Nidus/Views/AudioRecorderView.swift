//
//  AudioRecorderView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/25/25.
//

import CoreLocation
import OSLog
import SwiftUI

struct AudioStatusView: View {
	var hasPermissions: Bool
	var isRecording: Bool
	var onStopRecording: () -> Void
	var onStartRecording: () -> Void
	var recordingTime: TimeInterval
	var transcription: String

	private func formatTime(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}

	var body: some View {
		HStack {
			// Record button
			Button(action: {
				if isRecording {
					onStopRecording()
				}
				else {
					onStartRecording()
				}
			}) {
				Image(
					systemName: isRecording
						? "stop.circle.fill" : "mic.circle.fill"
				)
				.font(.system(size: 80))
				.foregroundColor(isRecording ? .red : .blue)
			}
			.disabled(!hasPermissions)

			// Permission status
			if hasPermissions {
				VStack(alignment: .leading) {
					// Recording status
					Text(
						isRecording
							? "Recording..." : "Ready to record"
					)
					.font(.headline)
					.foregroundColor(
						isRecording ? .red : .primary
					)
					// Recording duration
					if isRecording {
						Text("Duration: \(formatTime(recordingTime))")
							.font(.subheadline)
							.foregroundColor(.secondary)
					}
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
			Spacer()
		}
	}
}
struct AudioRecorderView: View {
	var audioRecorder: AudioRecorder
	init(_ a: AudioRecorder) {
		self.audioRecorder = a
	}
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			AudioStatusView(
				hasPermissions: audioRecorder.hasPermissions,
				isRecording: audioRecorder.isRecording,
				onStopRecording: audioRecorder.stopRecording,
				onStartRecording: audioRecorder.startRecording,
				recordingTime: audioRecorder.recordingTime,
				transcription: audioRecorder.transcribedText
			)
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
		).previewDisplayName("Not Recording")
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
