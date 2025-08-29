import SwiftUI

@MainActor
@Observable
class AudioPlaybackStore {
	var currentTime: TimeInterval = 0
	var duration: TimeInterval = 0
	var isLoaded = false
	var isPlaying = false

}
