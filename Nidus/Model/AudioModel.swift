import Foundation

struct AudioModel {
	var isRecording: Bool = false
	var locationWhileRecording: [H3Cell] = []
	var recordingDuration: TimeInterval = 0
	var recordingUUID: UUID? = nil
	var tags: [AudioTagMatch] = []
	var transcription: String? = nil

	static func fromTranscript(
		isRecording: Bool = true,
		recordingDuration: TimeInterval = 123,
		_ transcription: String
	) -> AudioModel {
		let tags: [AudioTagMatch] = AudioTagIdentifier.parseTags(transcription)
		return .init(
			isRecording: isRecording,
			recordingDuration: recordingDuration,
			tags: tags,
			transcription: transcription
		)
	}
}
