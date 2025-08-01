import Foundation

class ModelAudioPreview: ModelAudio {
	init(
		hasPermissionTranscription: Bool? = nil,
		isRecording: Bool = false,
		recordingDuration: TimeInterval = 0,
		transcription: String? = nil
	) {
		super.init()
		self.hasPermissionTranscription = hasPermissionTranscription
		self.isRecording = isRecording
		self.recordingDuration = recordingDuration
		self.transcription = transcription
	}
	override func toggleRecording() {
		isRecording.toggle()
	}
	override func withPermission(ok: @escaping () -> Void, cancel: @escaping () -> Void) {
		ok()
	}
}
