import Foundation

struct AudioModel {
	var isRecording: Bool = false
	var recordingDuration: TimeInterval = 0
	var tags: [AudioTag] = []
	var transcription: String? = nil
}
