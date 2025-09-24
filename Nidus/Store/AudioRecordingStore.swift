import SwiftUI

@MainActor
@Observable
class AudioRecordingStore {
	var hasPermissionMicrophone: Bool?
	var hasPermissionTranscription: Bool?
	var isRecording: Bool
	var knowledgeGraph: KnowledgeGraph?
	var locationWhileRecording: [AudioNoteBreadcrumb]
	var recordingDuration: TimeInterval
	var recordingUUID: UUID?
	var transcription: String?

	init(
		hasPermissionMicrophone: Bool? = nil,
		hasPermissionTranscription: Bool? = nil,
		isRecording: Bool = false,
		knowledgeGraph: KnowledgeGraph? = nil,
		recordingDuration: TimeInterval = 0,
		transcription: String? = nil
	) {
		self.hasPermissionMicrophone = hasPermissionMicrophone
		self.hasPermissionTranscription = hasPermissionTranscription
		self.isRecording = isRecording
		self.knowledgeGraph = knowledgeGraph
		self.locationWhileRecording = []
		self.recordingDuration = recordingDuration
		self.recordingUUID = nil
		self.transcription = transcription
	}
	static func fromTranscript(
		isRecording: Bool = true,
		recordingDuration: TimeInterval = 123,
		_ transcription: String
	) -> AudioRecordingStore {
		let knowledgeGraph = ExtractKnowledge(transcription)
		let result = AudioRecordingStore(knowledgeGraph: knowledgeGraph)
		result.isRecording = isRecording
		result.recordingDuration = recordingDuration
		//result.tags = tags
		result.transcription = transcription
		return result
	}
}
