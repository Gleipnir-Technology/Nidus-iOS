import SwiftUI

struct AudioDetailPane: View {
	let controller: AudioController
	@Binding var isShowing: Bool

	private func timeString(_ timeInterval: TimeInterval) -> String {
		let minutes = Int(timeInterval) / 60
		let seconds = Int(timeInterval) % 60
		return String(format: "%d:%02d", minutes, seconds)
	}

	var body: some View {
		VStack(spacing: 20) {
			Rectangle()
				.fill(Color.gray.opacity(0.3))
				.frame(width: 40, height: 5)
				.cornerRadius(3)
				.padding(.top, 10)

			Text("Recording Details")
				.font(.headline)

			if controller.model.isRecording {
				// Add your process details here
				VStack(alignment: .leading, spacing: 10) {
					Text(
						"Recording duration: \(timeString(controller.model.recordingDuration))"
					)
					if controller.hasPermissionTranscription == nil {
						Text("Not sure if we'll get permission or not")
						HStack {
							Spacer()
							ProgressView().padding(.horizontal)
							Spacer()
						}
					}
					else {
						if controller.hasPermissionTranscription! {
							if controller.model.transcription == nil {
								Text("Waiting to transcribe...")
							}
							else {
								TranscriptionDisplay(
									transcription: controller
										.model
										.transcription!
								)
								AudioTagDisplay(
									tags: controller.model.tags
								)
							}
						}
						else {
							Text(
								"Transcription not available, permission was denied"
							)
						}
					}

				}
				.padding()

			}
			else {
				Text("Not recording")
			}
		}
	}
}
struct AudioDetailPane_Previews: PreviewProvider {
	@State static var isShowing: Bool = true
	static var previews: some View {
		AudioDetailPane(controller: AudioControllerPreview(), isShowing: $isShowing)
			.previewDisplayName("Not recording")
		AudioDetailPane(
			controller: AudioControllerPreview(
				isRecording: true,
				recordingDuration: 60 * 2 + 15
			),
			isShowing: $isShowing
		).previewDisplayName(
			"recording"
		)

		VStack {
			Spacer().background(.blue)
			AudioDetailPane(
				controller: AudioControllerPreview(
					hasPermissionTranscription: true,
					isRecording: true,
					recordingDuration: 60 * 2 + 15,
					transcription: "This is a test transcription"
				),
				isShowing: $isShowing
			).background(.green)
		}.previewDisplayName(
			"with transcription"
		)

		VStack {
			Spacer().background(.blue)
			AudioDetailPane(
				controller: AudioControllerPreview(
					hasPermissionTranscription: true,
					isRecording: true,
					recordingDuration: 60 * 2 + 15,
					transcription: "This is a test transcription"
				),
				isShowing: $isShowing
			).background(.green)
		}.previewDisplayName(
			"with transcription with tags"
		)
	}
}
