import SwiftUI

struct ButtonAudioRecord: View {
	var audio: AudioRecordingController
	let actionLong: () -> Void

	func onMicButtonShort() {
		audio.withPermission(
			ok: {
				audio.toggleRecording()
			},
			cancel: {
				print("Permission not granted")
			}
		)
	}
	var body: some View {
		ButtonWithLongPress(
			actionLong: actionLong,
			actionShort: onMicButtonShort,
			isAnimated: audio.model.isRecording,
			label: {
				Image(
					systemName: audio.model.isRecording
						? "stop.circle.fill" : "mic"
				).font(
					.system(size: 64, weight: .regular)
				).foregroundColor(audio.model.isRecording ? .red : .gray).padding(
					20
				)
			}
		).foregroundColor(.secondary)
	}
}

struct ButtonAudioRecord_Previews: PreviewProvider {
	static func onLongPress() {

	}
	static var previews: some View {
		ButtonAudioRecord(audio: AudioRecordingControllerPreview(), actionLong: onLongPress)
	}
}
