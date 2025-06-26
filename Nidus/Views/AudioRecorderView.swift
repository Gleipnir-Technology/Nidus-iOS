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
				// Recording status
				Text(
					isRecording
						? "Recording..." : "Ready to record"
				)
				.font(.headline)
				.foregroundColor(
					isRecording ? .red : .primary
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
			if isRecording {
				Text("Duration: \(formatTime(recordingTime))")
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
			AudioStatusView(
				hasPermissions: audioRecorder.hasPermissions,
				isRecording: audioRecorder.isRecording,
				onStopRecording: audioRecorder.stopRecording,
				onStartRecording: audioRecorder.startRecording,
				recordingTime: audioRecorder.recordingTime

			)
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

		}
		.padding()
		.onAppear {
			audioRecorder.requestPermissions()
		}
	}

}

// MARK: - Preview
struct AudioRecorder_Previews: PreviewProvider {
	static var previews: some View {
		AudioRecorderView(audioRecorder: AudioRecorderFake(hasPermissions: false))
			.previewDisplayName("No Permissions")
		AudioRecorderView(audioRecorder: AudioRecorderFake(isRecording: false))
			.previewDisplayName("Not Recording")
		AudioRecorderView(
			audioRecorder: AudioRecorderFake(
				isRecording: true,
				recordingDuration: TimeInterval(integerLiteral: 98)
			)
		)
		.previewDisplayName("Is Recording")
	}
}
