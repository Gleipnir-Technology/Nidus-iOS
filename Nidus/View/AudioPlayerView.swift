import AVFoundation
import OSLog
import SwiftUI

struct AudioPlayerView: View {
	@StateObject private var audioManager = AudioManager()
	var recording: AudioNote

	func loadAudio(_ recording: AudioNote) {
		audioManager.loadAudio(recording)
	}

	var body: some View {
		VStack(spacing: 12) {
			// Progress slider with time labels
			VStack(spacing: 4) {
				Slider(
					value: Binding(
						get: { audioManager.currentTime },
						set: { audioManager.seek(to: $0) }
					),
					in: 0...audioManager.duration
				)
				.disabled(!audioManager.isLoaded)

				// Time labels
				HStack {
					Text(timeString(from: audioManager.currentTime))
						.font(.caption2)
						.foregroundColor(.secondary)

					Spacer()

					Text(timeString(from: audioManager.duration))
						.font(.caption2)
						.foregroundColor(.secondary)
				}
			}

			// Compact control buttons
			HStack(spacing: 24) {
				// Skip backward 15 seconds
				Button(action: { audioManager.skip(-15) }) {
					Image(systemName: "gobackward.15")
						.font(.title3)
				}
				.disabled(!audioManager.isLoaded)

				// Play/Pause button
				Button(action: audioManager.togglePlayPause) {
					Image(
						systemName: audioManager.isPlaying
							? "pause.circle.fill" : "play.circle.fill"
					)
					.font(.system(size: 40))
				}
				.disabled(!audioManager.isLoaded)

				// Skip forward 15 seconds
				Button(action: { audioManager.skip(15) }) {
					Image(systemName: "goforward.15")
						.font(.title3)
				}
				.disabled(!audioManager.isLoaded)
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(Color(.systemGray6))
		.cornerRadius(12)
		.onAppear {
			loadAudio(recording)
		}
		.onChange(of: recording) { _, newRecording in
			audioManager.loadAudio(newRecording)
		}
		.onDisappear {
			audioManager.stop()
		}
	}

	private func timeString(from timeInterval: TimeInterval) -> String {
		let minutes = Int(timeInterval) / 60
		let seconds = Int(timeInterval) % 60
		return String(format: "%d:%02d", minutes, seconds)
	}
}

@MainActor
class AudioManager: ObservableObject {
	@Published var isPlaying = false
	@Published var isLoaded = false
	@Published var currentTime: TimeInterval = 0
	@Published var duration: TimeInterval = 0

	var recording: AudioNote?

	private var audioDelegate: AudioPlayerDelegate2?
	private var audioPlayer: AVAudioPlayer?
	private var timer: Timer?

	init() {
		setupAudioSession()
	}

	private func setupAudioSession() {
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
			try AVAudioSession.sharedInstance().setActive(true)
		}
		catch {
			print("Failed to setup audio session: \(error)")
		}
	}

	func loadAudio(_ recording: AudioNote) {
		self.recording = recording
		// Make sure to add your audio file to your app bundle
		do {
			audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
			audioDelegate = AudioPlayerDelegate2(manager: self)
			audioPlayer?.delegate = audioDelegate
			audioPlayer?.prepareToPlay()

			duration = audioPlayer?.duration ?? 0
			isLoaded = true
		}
		catch {
			print("Error loading audio: \(error)")
		}
	}

	func togglePlayPause() {
		if audioPlayer == nil {
			Logger.foreground.warning(
				"Cannot toggle play/pause because the player is nil"
			)
			return
		}

		if isPlaying {
			pause()
		}
		else {
			play()
		}
	}

	func play() {
		audioPlayer?.play()
		isPlaying = true
		startTimer()
	}

	func pause() {
		audioPlayer?.pause()
		isPlaying = false
		stopTimer()
	}

	func stop() {
		audioPlayer?.stop()
		audioPlayer?.currentTime = 0
		isPlaying = false
		currentTime = 0
		stopTimer()
	}

	func seek(to time: TimeInterval) {
		audioPlayer?.currentTime = time
		currentTime = time
	}

	func skip(_ seconds: TimeInterval) {
		guard let player = audioPlayer else { return }
		let newTime = max(0, min(player.currentTime + seconds, duration))
		seek(to: newTime)
	}

	private func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
			Task { @MainActor in
				self.currentTime = self.audioPlayer?.currentTime ?? 0
			}
		}
	}

	func stopTimer() {
		timer?.invalidate()
		timer = nil
	}
}

class AudioPlayerDelegate2: NSObject, AVAudioPlayerDelegate {
	let manager: AudioManager

	init(manager: AudioManager) {
		self.manager = manager
	}

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		Task { @MainActor in
			manager.isPlaying = false
			manager.currentTime = 0
			manager.stopTimer()
		}
	}
}
