import SwiftUI

struct ButtonAudioRecord: View {
	var audio: ModelAudio
	@Binding var didSelect: Bool

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
	func onMicButtonLong() {
		didSelect.toggle()
	}
	var body: some View {
		ButtonWithLongPress(
			actionLong: onMicButtonLong,
			actionShort: onMicButtonShort,
			isAnimated: audio.isRecording,
			label: {
				Image(
					systemName: audio.isRecording
						? "stop.circle.fill" : "mic"
				).font(
					.system(size: 64, weight: .regular)
				).foregroundColor(audio.isRecording ? .red : .gray).padding(
					20
				)
			}
		).foregroundColor(.secondary)
	}
}

struct ButtonAudioRecord_Previews: PreviewProvider {
	@State static var didSelect: Bool = false
	static var previews: some View {
		ButtonAudioRecord(audio: PreviewAudio(), didSelect: $didSelect)
	}
}
