import SwiftUI

/*
 Root store of application state for the entire application
 */
@MainActor
@Observable
class RootStore {
	let audioPlayback: AudioPlaybackStore
	let audioRecording: AudioRecordingStore
	init() {
		audioPlayback = AudioPlaybackStore()
		audioRecording = AudioRecordingStore()
	}
}
