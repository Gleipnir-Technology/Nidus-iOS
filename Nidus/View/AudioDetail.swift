import SwiftUI

struct AudioDetail: View {
	var audio: AudioRecordingController
	var body: some View {
		if audio.model.isRecording {
			AudioStatusRecordingView(
				hasPermissions: audio.hasPermissionMicrophone!,
				recordingTime: audio.model.recordingDuration,
				transcription: audio.model.transcription
			)
		}
		else {
			AudioStatusIdleView(
				playRecording: audio.playRecording
			)
		}
	}
}
struct AudioStatusIdleView: View {
	var playRecording: (URL) -> Void
	var recordings: [AudioRecording] = []

	var durationDisplay: String {
		let duration = recordingTime
		if duration < 20 {
			return String(format: "%.1f s total", duration)
		}
		else if duration < 60 * 2 {
			return String(format: "%.0f s total", duration)
		}
		else {
			let minutes = Int(duration) / 60
			let remainder = Int(duration) % 60
			return String(format: "%dm %ds total", minutes, remainder)
		}
	}
	var recordingTime: Double {
		return recordings.reduce(
			0.0,
			{ accumulator, next in
				accumulator + next.duration
			}
		)
	}
	var recordingCount: String {
		if recordings.count == 1 {
			return "1 clip"
		}
		else {
			return "\(recordings.count) clips"
		}
	}

	var recordingList: some View {
		HStack {
			VStack(alignment: .leading, spacing: 10) {
				Text(recordingCount)
				Text(durationDisplay)
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
