//
//  AudioRecorderView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/25/25.
//

import CoreLocation
import OSLog
import SwiftUI

/*
struct AudioStatusView: View {
	@Binding var audioRecorder: AudioRecorder
	var body: some View {
	}
}*/
struct AudioRecorderView: View {
	@State private var audioRecorder: AudioRecorder

	init(audioRecorder: AudioRecorder) {
		self._audioRecorder = .init(wrappedValue: audioRecorder)
	}

	init() {
		self.init(audioRecorder: AudioRecorder())
	}

	private func formatTime(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			//AudioStatusView(audioRecorder: $audioRecorder)
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
					Text(
						audioRecorder.isRecording
							? "Recording..." : "Ready to record"
					)
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
		AudioRecorderView(audioRecorder: AudioRecorderFake(isRecording: true))
			.previewDisplayName("Is Recording")
	}
}
