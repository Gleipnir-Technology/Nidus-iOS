import OSLog
import SwiftUI

@Observable
class AudioController {
	var model: AudioModel = AudioModel()
	var errorMessage: String = ""
	var hasPermissionMicrophone: Bool? = nil
	var hasPermissionTranscription: Bool? = nil

	private var timer: Timer?
	private var wrapper: WrapperAudio = WrapperAudio()

	func playRecording(_ url: URL) {

	}

	func toggleRecording() {
		if model.isRecording {
			wrapper.stopRecording()
			model.isRecording = false
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
				model.recordingDuration = 0
				model.isRecording = true
				// Start timer for recording duration
				timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
					_ in
					self.model.recordingDuration += 1
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
		self.model.transcription = transcription
		self.model.tags = AudioTagIdentifier.parseTags(transcription)
	}

}

class AudioControllerPreview: AudioController {
	init(
		hasPermissionTranscription: Bool? = nil,
		model: AudioModel = AudioModel()
	) {
		super.init()
		self.hasPermissionTranscription = hasPermissionTranscription
		self.model = model
	}
	override func toggleRecording() {
		model.isRecording.toggle()
	}
	override func withPermission(ok: @escaping () -> Void, cancel: @escaping () -> Void) {
		ok()
	}
}
