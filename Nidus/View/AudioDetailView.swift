import SwiftUI

struct AudioDetailView: View {
	let controller: AudioRecordingController

	private func timeString(_ timeInterval: TimeInterval) -> String {
		let minutes = Int(timeInterval) / 60
		let seconds = Int(timeInterval) % 60
		return String(format: "%d:%02d", minutes, seconds)
	}

	var body: some View {
		VStack(spacing: 20) {
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
									tags: controller.model.tags,
									transcription: controller
										.model.transcription
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
struct AudioDetailView_Previews: PreviewProvider {
	static var previews: some View {
		AudioDetailView(controller: AudioRecordingControllerPreview())
			.previewDisplayName("Not recording")
		AudioDetailView(
			controller: AudioRecordingControllerPreview(
				model: AudioModel(
					isRecording: true,
					recordingDuration: 60 * 2 + 15
				)
			)
		).previewDisplayName(
			"recording"
		)

		VStack {
			Spacer().background(.blue)
			AudioDetailView(
				controller: AudioRecordingControllerPreview(
					hasPermissionTranscription: true,
					model: AudioModel(
						isRecording: true,
						recordingDuration: 60 * 2 + 15,
						transcription: "This is a test transcription"
					)
				)
			).background(.green)
		}.previewDisplayName(
			"with transcription"
		)

		VStack {
			Spacer().background(.blue)
			AudioDetailView(
				controller: AudioRecordingControllerPreview(
					hasPermissionTranscription: true,
					model: AudioModel.fromTranscript(
						"Checking orchards at Avenue 300 and Road 140. 92 degrees, full sun. Rows five through nine have deep ruts still wet from last week’s flood irrigation. Soil is clay-heavy, tractor ruts holding water. Orchard is mature citrus. Took five dips, each with between twenty and a hundred larvae, mostly third and fourth instar Culex. Treated rut areas with one pound of VectoMax FG. Spoke with Jim, the foreman who manages the site. Told him the ruts are producing mosquitoes — he said he’ll have someone grade them before the next irrigation in two weeks. Gave me his number 559-555-5555 and said to call if anything comes up. Need to check back in two weeks to confirm the issue’s resolved."
					)
				)
			)
		}.previewDisplayName(
			"with transcription with tags"
		)
	}
}
