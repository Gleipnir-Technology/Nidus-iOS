import OSLog
import SwiftUI

@Observable
class ModelAudio {
	var isRecording: Bool = false
	var errorMessage: String = ""
	var hasPermissionMicrophone: Bool? = nil
	var hasPermissionTranscription: Bool? = nil
	var recordingDuration: TimeInterval = 0
	var transcription: String? = nil

	private var timer: Timer?
	private var wrapper: WrapperAudio = WrapperAudio()

	func playRecording(_ url: URL) {

	}

	func toggleRecording() {
		if isRecording {
			wrapper.stopRecording()
			isRecording = false
			timer?.invalidate()
			timer = nil
			/*
             // save recording
            let recording = AudioRecording(
                created: Date.now,
                duration: recordingDuration,
                transcription: recordingTranscription,
                uuid: recordingUUID
            )
             */
		}
		else {
			do {
				wrapper.onTranscriptionUpdate(onTranscriptionUpdate)
				try wrapper.startRecording()
				recordingDuration = 0
				isRecording = true
				// Start timer for recording duration
				timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
					_ in
					self.recordingDuration += 1
				}

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
			wrapper.requestPermissions { hasMic, hasTranscript in
				self.hasPermissionMicrophone = hasMic
				self.hasPermissionTranscription = hasTranscript
				Logger.foreground.info(
					"Audio permissions: \(hasMic), \(hasTranscript)"
				)
				if hasMic {
					ok()
				}
				else {
					cancel()
				}
			}
		}
	}

	private func onTranscriptionUpdate(_ transcription: String) {
		self.transcription = transcription
	}
}
