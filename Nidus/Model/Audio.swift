import SwiftUI

@Observable
class ModelAudio {
	var isRecording: Bool = false
	var hasPermissions: Bool = false
	var recordingTime: TimeInterval = 0
	var transcription: String? = nil
	private var wrapper: WrapperAudio = WrapperAudio()

	var recordingDuration: TimeInterval {
		return TimeInterval()
	}

	func playRecording(_ url: URL) {

	}
	func toggleRecording() {
		if wrapper.isRecording {
			wrapper.stopRecording()
		}
		else {
			wrapper.startRecording()
		}
	}
}
