import SwiftUI

struct ButtonAudioRecord: View {
	let actionLong: () -> Void
	var controller: RootController

	func onMicButtonShort() {
		controller.audioRecording.withPermission(
			ok: {
				controller.toggleAudioRecording()
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
			isAnimated: controller.audioRecording.store.isRecording,
			label: {
				Image(
					systemName: controller.audioRecording.store.isRecording
						? "stop.circle.fill" : "mic"
				).font(
					.system(size: 64, weight: .regular)
				).foregroundColor(
					controller.audioRecording.store.isRecording ? .red : .gray
				).padding(
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
		ButtonAudioRecord(actionLong: onLongPress, controller: RootControllerPreview())
	}
}
