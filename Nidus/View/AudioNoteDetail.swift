import AVFoundation
import H3
import MapKit
import OSLog
import SwiftUI

/// Simple widget for doing playback with pause/play and skip forward/back and a sweeper
struct AudioPlaybackWidget: View {
	var controller: AudioPlaybackController

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
		.onDisappear {
			controller.stop()
		}
	}
}

struct AudioNoteDetail: View {
	var controller: AudioPlaybackController
	let note: AudioNote

	private func initialRegion() -> MKCoordinateRegion {
		var sumLat = 0.0
		var sumLong = 0.0
		var minLat = 180.0
		var minLong = 180.0
		var maxLat = -180.0
		var maxLong = -180.0
		for cell in note.locations {
			do {
				let latLong = try cellToLatLng(cell: cell)
				sumLat += latLong.latitude
				sumLong += latLong.longitude

				if latLong.latitude < minLat {
					minLat = latLong.latitude
				}
				if latLong.latitude > maxLat {
					maxLat = latLong.latitude
				}
				if latLong.longitude < minLong {
					minLong = latLong.longitude
				}
				if latLong.longitude > maxLong {
					maxLong = latLong.longitude
				}
			}
			catch {
				Logger.foreground.warning("Failed to parse cell \(cell)")
			}
		}

		let center = CLLocationCoordinate2D(
			latitude: sumLat / Double(note.locations.count),
			longitude: sumLong / Double(note.locations.count)
		)

		return MKCoordinateRegion(
			center: center,
			span: MKCoordinateSpan(
				latitudeDelta: maxLat - minLat,
				longitudeDelta: maxLong - minLong
			)
		)
	}

	var body: some View {
		VStack {
			if note.locations.count == 0 {
				Text("No location")
			}
			else {
				MapViewBreadcrumb(
					breadcrumbCells: note.locations,
					initialRegion: initialRegion(),
					notes: nil,
					region: nil,
					showsGrid: false
				)
			}
			AudioPlaybackWidget(
				controller: controller
			)
			if note.transcription != nil && !(note.transcription!.isEmpty) {
				TranscriptionDisplay(
					tags: note.tags,
					transcription: note.transcription
				)
			}
		}
		.onAppear {
			controller.loadAudio(note.id)
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
