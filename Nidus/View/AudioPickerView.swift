import AVFoundation
import SwiftUI

struct AudioPickerView: View {
	@State private var currentlyPlayingIndex: Int?
	@Environment(\.dismiss) private var dismiss  // moved dismiss functionality here
	@State private var isPlaying = false
	@State private var playbackProgress: Double = 0.0
	@Binding var recordings: [AudioRecording]
	@State private var selectedIndex: Int
	@State private var selectedRecording: AudioRecording
	@State private var timer: Timer?

	// Callback for when items are removed
	let onItemsChanged: ([URL]) -> Void

	init(_ recordings: Binding<[AudioRecording]>, _ onItemsChanged: @escaping ([URL]) -> Void) {
		self._recordings = .init(projectedValue: recordings)
		self.selectedIndex = 0
		self.selectedRecording = self._recordings[0].wrappedValue
		self.onItemsChanged = onItemsChanged
	}

	private func onDelete(at: Int) {
		if selectedIndex == at {
			selectedIndex = 0
		}
		recordings.remove(at: at)
		if recordings.isEmpty {
			dismiss()
		}
	}

	private func onSelect(at: Int) {
		selectedIndex = at
		selectedRecording = recordings[at]
	}

	var body: some View {
		NavigationView {
			VStack {
				AudioPlayerView(recording: selectedRecording)
				List {
					ForEach(Array(recordings.enumerated()), id: \.offset) {
						index,
						recording in
						AudioRowView(
							isSelected: (index == selectedIndex),
							onDelete: { onDelete(at: index) },
							onSelect: { onSelect(at: index) },
							recording: recording
						)
					}
				}
				.navigationTitle("Audio Recordings")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button("Close") {
							dismiss()
						}
					}
				}
			}
		}
	}
}

struct AudioRowView: View {
	let isSelected: Bool
	let onDelete: () -> Void
	let onSelect: () -> Void
	let recording: AudioRecording

	private var durationDisplay: String {
		return "\(recording.duration)s"
	}

	var body: some View {
		VStack {
			HStack {
				Text(recording.created, style: .relative)
				Spacer()
				Text(durationDisplay)
				Button(action: onSelect) {
					Image(systemName: isSelected ? "play.fill" : "play")
						.font(.title3)
						.foregroundColor(isSelected ? .green : .blue)
				}
			}
			Text(recording.transcription ?? "no transcript").font(.caption)
		}
	}
}

// Helper class to handle audio player delegate
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
	let onFinish: () -> Void

	init(onFinish: @escaping () -> Void) {
		self.onFinish = onFinish
	}

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		onFinish()
	}
}

// Preview
struct AudioPickerView_Previews: PreviewProvider {
	@State static var sampleRecordings = [
		AudioRecording(
			created: Date.now.addingTimeInterval(-100),
			duration: TimeInterval(integerLiteral: 10)
		),
		AudioRecording(
			created: Date.now.addingTimeInterval(-50),
			duration: TimeInterval(integerLiteral: 10)
		),
		AudioRecording(
			created: Date.now.addingTimeInterval(-10),
			duration: TimeInterval(integerLiteral: 10)
		),
	]

	static var previews: some View {
		// Create some sample URLs for preview
		AudioPickerView($sampleRecordings) { updatedURIs in
			print("Updated URIs: \(updatedURIs)")
		}
	}
}
