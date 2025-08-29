import AVFoundation
import OSLog
import SwiftUI

class AudioPlaybackController: NSObject, AVAudioPlayerDelegate {
	private var audioPlayer: AVAudioPlayer?
	internal let store: AudioPlaybackStore
	private var timer: Timer?

	init(_ store: AudioPlaybackStore) {
		self.store = store
	}

	@MainActor
	func loadAudio(_ uuid: UUID) {
		do {
			audioPlayer = try AVAudioPlayer(
				contentsOf: AudioPlaybackController.url(uuid)
			)
			audioPlayer?.delegate = self
			audioPlayer?.prepareToPlay()

			store.duration = audioPlayer?.duration ?? 0
			store.isLoaded = true
		}
		catch {
			print("Error loading audio: \(error)")
		}
	}

	@MainActor
	func play() {
		audioPlayer?.play()
		startTimer()
		store.isPlaying = true
	}

	@MainActor
	func seek(to time: TimeInterval) {
		store.currentTime = time
	}

	@MainActor
	func skip(_ seconds: TimeInterval) {
		guard let player = audioPlayer else { return }
		let newTime = max(0, min(player.currentTime + seconds, store.duration))
		seek(to: newTime)
	}

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		Task { @MainActor in
			store.isPlaying = false
			store.currentTime = 0
			stopTimer()
		}
	}

	@MainActor
	func stop() {
		audioPlayer?.stop()
		audioPlayer?.currentTime = 0
		store.isPlaying = false
		store.currentTime = 0
		stopTimer()
	}

	@MainActor
	func togglePlayPause() {
		if audioPlayer == nil {
			Logger.foreground.warning(
				"Cannot toggle play/pause because the player is nil"
			)
			return
		}

		if store.isPlaying {
			pause()
		}
		else {
			play()
		}
	}

	private func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
			Task { @MainActor in
				self.store.currentTime = self.audioPlayer?.currentTime ?? 0
			}
		}
	}

	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}

	static func url(_ uuid: UUID) -> URL {
		let supportURL = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		)
		return supportURL.appendingPathComponent("\(uuid).m4a")
	}
}

class AudioPlaybackControllerPreview: AudioPlaybackController {
	@MainActor
	init() {
		let store = AudioPlaybackStore()
		super.init(store)
	}
	@MainActor
	override func loadAudio(_ uuid: UUID) {
		store.isLoaded = true
	}
}
