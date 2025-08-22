import OSLog
import SwiftUI

@Observable
class AudioRecordingController {
	var errorMessage: String = ""
	var hasPermissionMicrophone: Bool? = nil
	var hasPermissionTranscription: Bool? = nil
	var model: AudioModel = AudioModel()
	var recordingSaveCallbacks: [(AudioNote) -> Void] = []

	private var timer: Timer?
	private var wrapper: WrapperAudio = WrapperAudio()

	func onLocationUpdated(_ cells: [H3Cell]) {
		if model.isRecording {
			for cell in cells {

				if model.locationWhileRecording.isEmpty
					|| model.locationWhileRecording[
						model.locationWhileRecording.count - 1
					].cell != cell
				{
					model.locationWhileRecording.append(
						AudioNoteBreadcrumb(cell: cell, created: Date.now)
					)
				}
			}
		}
	}

	func onRecordingSave(_ callback: @escaping (AudioNote) -> Void) {
		recordingSaveCallbacks.append(callback)
	}

	func playRecording(_ url: URL) {

	}

	func toggleRecording() {
		if model.isRecording {
			wrapper.stopRecording()
			model.isRecording = false
			timer?.invalidate()
			timer = nil
			// save recording
			let note = AudioNote(
				id: model.recordingUUID!,
				breadcrumbs: model.locationWhileRecording,
				created: Date.now,
				duration: model.recordingDuration,
				transcription: model.transcription
			)
			handleRecordingSave(note)
		}
		else {
			do {
				wrapper.onTranscriptionUpdate(onTranscriptionUpdate)
				model.recordingUUID = UUID()
				model.locationWhileRecording = []
				try wrapper.startRecording(model.recordingUUID!)
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

	private func handleRecordingSave(_ recording: AudioNote) {
		for callback in recordingSaveCallbacks {
			callback(recording)
		}
	}
	private func onTranscriptionUpdate(_ transcription: String) {
		self.model.transcription = transcription
		self.model.tags = AudioTagIdentifier.parseTags(transcription)
	}

}

class AudioRecordingControllerPreview: AudioRecordingController {
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
