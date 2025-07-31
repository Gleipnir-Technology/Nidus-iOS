import SwiftUI

struct ButtonAudioRecord: View {
	var audioRecorder: ModelAudio
	@Binding var didSelect: Bool

	func onMicButtonShort() {
		/*if !audioRecorder.hasPermissions {
            audioRecorder.requestPermissions()
            }
        audioRecorder.toggleRecording()*/
	}
	func onMicButtonLong() {
		didSelect.toggle()
		print("mic long!")
	}
	var body: some View {
		ButtonWithLongPress(
			actionLong: onMicButtonLong,
			actionShort: onMicButtonShort,
			label: {
				Image(
					systemName: audioRecorder.isRecording
						? "stop.circle.fill" : "mic"
				).font(
					.system(size: 64, weight: .regular)
				).foregroundColor(audioRecorder.isRecording ? .red : .gray).padding(
					20
				)
			}
		).disabled(!audioRecorder.hasPermissions).foregroundColor(.secondary)
	}
}
