class PreviewAudio: ModelAudio {

	override func toggleRecording() {
		isRecording.toggle()
	}
	override func withPermission(ok: @escaping () -> Void, cancel: @escaping () -> Void) {
		ok()
	}
}
