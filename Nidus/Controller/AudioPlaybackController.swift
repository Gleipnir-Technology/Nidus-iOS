import AVFoundation
import OSLog
import SwiftUI

@Observable
class AudioPlaybackController: NSObject, AVAudioPlayerDelegate {
	private var audioPlayer: AVAudioPlayer?
	var currentTime: TimeInterval = 0
	var duration: TimeInterval = 0
	var isLoaded = false
	var isPlaying = false
	private var timer: Timer?

	func loadAudio(_ uuid: UUID) {
		do {
			audioPlayer = try AVAudioPlayer(
				contentsOf: AudioPlaybackController.url(uuid)
			)
			audioPlayer?.delegate = self
			audioPlayer?.prepareToPlay()

			duration = audioPlayer?.duration ?? 0
			isLoaded = true
		}
		catch {
			print("Error loading audio: \(error)")
		}
	}

	func play() {
		audioPlayer?.play()
		isPlaying = true
		startTimer()
	}

	func seek(to time: TimeInterval) {
		currentTime = time
	}

	func skip(_ seconds: TimeInterval) {
		guard let player = audioPlayer else { return }
		let newTime = max(0, min(player.currentTime + seconds, duration))
		seek(to: newTime)
	}

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		Task { @MainActor in
			isPlaying = false
			currentTime = 0
			stopTimer()
		}
	}

	func stop() {
		audioPlayer?.stop()
		audioPlayer?.currentTime = 0
		isPlaying = false
		currentTime = 0
		stopTimer()
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

	private func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
			Task { @MainActor in
				self.currentTime = self.audioPlayer?.currentTime ?? 0
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
	override init() {
		super.init()
	}
	override func loadAudio(_ uuid: UUID) {
		isLoaded = true
	}
}
