import AVFoundation
import OSLog
import SwiftUI

struct AudioNoteDetail: View {
	var controller: AudioPlaybackController
	let note: AudioNote

	private func timeString(from timeInterval: TimeInterval) -> String {
		let minutes = Int(timeInterval) / 60
		let seconds = Int(timeInterval) % 60
		return String(format: "%d:%02d", minutes, seconds)
	}

	var body: some View {
		VStack(spacing: 12) {
			// Progress slider with time labels
			VStack(spacing: 4) {
				Slider(
					value: Binding(
						get: { controller.currentTime },
						set: { controller.seek(to: $0) }
					),
					in: 0...controller.duration
				)
				.disabled(!controller.isLoaded)

				// Time labels
				HStack {
					Text(timeString(from: controller.currentTime))
						.font(.caption2)
						.foregroundColor(.secondary)

					Spacer()

					Text(timeString(from: controller.duration))
						.font(.caption2)
						.foregroundColor(.secondary)
				}
			}

			// Compact control buttons
			HStack(spacing: 24) {
				// Skip backward 15 seconds
				Button(action: { controller.skip(-15) }) {
					Image(systemName: "gobackward.15")
						.font(.title3)
				}
				.disabled(!controller.isLoaded)

				// Play/Pause button
				Button(action: controller.togglePlayPause) {
					Image(
						systemName: controller.isPlaying
							? "pause.circle.fill" : "play.circle.fill"
					)
					.font(.system(size: 40))
				}
				.disabled(!controller.isLoaded)

				// Skip forward 15 seconds
				Button(action: { controller.skip(15) }) {
					Image(systemName: "goforward.15")
						.font(.title3)
				}
				.disabled(!controller.isLoaded)
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(Color(.systemGray6))
		.cornerRadius(12)
		.onAppear {
			controller.loadAudio(note.id)
		}
		.onDisappear {
			controller.stop()
		}
	}
}

struct AudioNoteDetail_Previews: PreviewProvider {
	static var previews: some View {
		AudioNoteDetail(
			controller: AudioPlaybackControllerPreview(),
			note: AudioNote.Preview.one
		)
	}
}
