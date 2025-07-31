import SwiftUI

@Observable
class ModelAudio {
	var isRecording: Bool = false
	var errorMessage: String = ""
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
		if isRecording {
			wrapper.stopRecording()
			isRecording = false
		}
		else {
			do {
				try wrapper.startRecording()
				isRecording = true
			}
			catch {
				self.errorMessage = error.localizedDescription
			}
		}
	}

	func withPermission(ok: @escaping () -> Void, cancel: @escaping () -> Void) {
		if wrapper.hasMicrophonePermission {
			ok()
		}
		else {
			wrapper.requestPermissions { granted in
				if granted {
					ok()
				}
				else {
					cancel()
				}
			}
		}
	}
}
