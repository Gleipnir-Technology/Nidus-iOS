import SwiftUI

/*
 Root store of application state for the entire application
 */
@MainActor
@Observable
class RootStore {
	let audioPlayback: AudioPlaybackStore
	let audioRecording: AudioRecordingStore
	let region: RegionStore
	init() {
		audioPlayback = AudioPlaybackStore()
		audioRecording = AudioRecordingStore()
		region = RegionStore()
	}
}
