import SwiftUI

@MainActor
@Observable
class AudioRecordingStore {
	var hasPermissionMicrophone: Bool?
	var hasPermissionTranscription: Bool?
	var isRecording: Bool
	var locationWhileRecording: [AudioNoteBreadcrumb]
	var recordingDuration: TimeInterval
	var recordingUUID: UUID?
	var tags: [AudioTagMatch]
	var transcription: String?

	init(
		hasPermissionMicrophone: Bool? = nil,
		hasPermissionTranscription: Bool? = nil,
		isRecording: Bool = false,
		recordingDuration: TimeInterval = 0,
		transcription: String? = nil
	) {
		self.hasPermissionMicrophone = hasPermissionMicrophone
		self.hasPermissionTranscription = hasPermissionTranscription
		self.isRecording = isRecording
		self.locationWhileRecording = []
		self.recordingDuration = recordingDuration
		self.recordingUUID = nil
		self.tags = []
		self.transcription = transcription
	}
	static func fromTranscript(
		isRecording: Bool = true,
		recordingDuration: TimeInterval = 123,
		_ transcription: String
	) -> AudioRecordingStore {
		let tags: [AudioTagMatch] = AudioTagIdentifier.parseTags(transcription)
		let result = AudioRecordingStore()
		result.isRecording = isRecording
		result.recordingDuration = recordingDuration
		result.tags = tags
		result.transcription = transcription
		return result
	}
}
