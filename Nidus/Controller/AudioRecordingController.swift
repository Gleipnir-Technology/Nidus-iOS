import OSLog
import Sentry
import SwiftUI

class AudioRecordingController {
	internal let store: AudioRecordingStore
	private var timer: Timer?
	private var wrapper: WrapperAudio

	init(_ store: AudioRecordingStore) {
		self.store = store
		self.timer = nil
		self.wrapper = WrapperAudio()
	}

	@MainActor
	func onLocationUpdated(_ cells: [H3Cell]) {
		if store.isRecording {
			for cell in cells {

				if store.locationWhileRecording.isEmpty
					|| store.locationWhileRecording[
						store.locationWhileRecording.count - 1
					].cell != cell
				{
					store.locationWhileRecording.append(
						AudioNoteBreadcrumb(cell: cell, created: Date.now)
					)
				}
			}
		}
	}

	func playRecording(_ url: URL) {

	}

	@MainActor
	func startRecording() {
		do {
			wrapper.onTranscriptionUpdate(onTranscriptionUpdate)
			store.recordingUUID = UUID()
			store.locationWhileRecording = []
			try wrapper.startRecording(store.recordingUUID!)
			store.recordingDuration = 0
			store.isRecording = true
			// Start timer for recording duration
			timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
				Task { @MainActor in
					self.store.recordingDuration += 1
				}
			}

		}
		catch {
			SentrySDK.capture(error: error)
			Logger.foreground.error("Failed to start recording: \(error)")
		}
	}

	@MainActor
	func stopRecording() -> AudioNote {
		wrapper.stopRecording()
		store.isRecording = false
		timer?.invalidate()
		timer = nil
		// save recording
		let note = AudioNote(
			id: store.recordingUUID!,
			breadcrumbs: store.locationWhileRecording,
			created: Date.now,
			duration: store.recordingDuration,
			transcription: store.transcription,
			transcriptionUserEdited: false,
			version: 1
		)
		return note
	}

	func withPermission(ok: @escaping () -> Void, cancel: @escaping () -> Void) {
		if wrapper.hasMicrophonePermission {
			ok()
		}
		else {
			wrapper.requestPermissions { hasMic, hasTranscript in
				Task { @MainActor in
					self.store.hasPermissionMicrophone = hasMic
					self.store.hasPermissionTranscription = hasTranscript
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
	}

	@MainActor
	private func onTranscriptionUpdate(_ transcription: String) {
		self.store.transcription = transcription
		self.store.tags = AudioTagIdentifier.parseTags(transcription)
	}

}

class AudioRecordingControllerPreview: AudioRecordingController {
	override func startRecording() {
		store.isRecording = true
	}
	override func stopRecording() -> AudioNote {
		return AudioNote(breadcrumbs: [], duration: 123, version: 1)
	}
	override func withPermission(ok: @escaping () -> Void, cancel: @escaping () -> Void) {
		ok()
	}
}
