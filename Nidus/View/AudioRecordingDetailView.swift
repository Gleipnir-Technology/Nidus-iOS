import SwiftUI

struct AudioRecordingDetailView: View {
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

			if controller.store.isRecording {
				VStack(alignment: .leading, spacing: 10) {
					Text(
						"Recording duration: \(timeString(controller.store.recordingDuration))"
					)
					if controller.store.hasPermissionTranscription == nil {
						Text("Not sure if we'll get permission or not")
						HStack {
							Spacer()
							ProgressView().padding(.horizontal)
							Spacer()
						}
					}
					else {
						if controller.store.hasPermissionTranscription! {
							if controller.store.transcription == nil {
								Text("Waiting to transcribe...")
							}
							else {
								TranscriptionDisplay(
									knowledgeGraph: controller
										.store
										.knowledgeGraph,
									transcription: controller
										.store.transcription
								)
								AudioTagDisplay(
									knowledge: controller.store
										.knowledgeGraph
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

struct AudioRecordingDetailViewPreview: View {
	var transcription: String

	init(_ transcription: String) {
		self.transcription = transcription
	}
	var body: some View {
		AudioRecordingDetailView(
			controller: AudioRecordingControllerPreview(
				AudioRecordingStore(
					hasPermissionTranscription: true,
					isRecording: true,
					knowledgeGraph: nil,
					transcription: transcription
				)
			)
		)
	}
}

struct AudioDetailView_Previews: PreviewProvider {
	static var previews: some View {
		let store = AudioRecordingStore()
		AudioRecordingDetailView(controller: AudioRecordingControllerPreview(store))
			.previewDisplayName("Not recording")
		AudioRecordingDetailView(
			controller: AudioRecordingControllerPreview(
				AudioRecordingStore(
					isRecording: true,
					recordingDuration: 60 * 2 + 15
				)
			)
		).previewDisplayName(
			"recording"
		)

		VStack {
			Spacer().background(.blue)
			AudioRecordingDetailView(
				controller: AudioRecordingControllerPreview(
					AudioRecordingStore(
						hasPermissionTranscription: true,
						isRecording: true,
						recordingDuration: 60 * 2 + 15,
						transcription: "This is a test transcription"
					)
				)
			)
		}.previewDisplayName(
			"with transcription"
		)

		VStack {
			Spacer()
			AudioRecordingDetailViewPreview(
				"Checking orchards at Avenue 300 and Road 140. 92 degrees, full sun. Rows five through nine have deep ruts still wet from last week’s flood irrigation. Soil is clay-heavy, tractor ruts holding water. Orchard is mature citrus. Took five dips, each with between twenty and a hundred larvae, mostly third and fourth instar Culex. Treated rut areas with one pound of VectoMax FG. Spoke with Jim, the foreman who manages the site. Told him the ruts are producing mosquitoes — he said he’ll have someone grade them before the next irrigation in two weeks. Gave me his number 559-555-5555 and said to call if anything comes up. Need to check back in two weeks to confirm the issue’s resolved."
			)
		}.previewDisplayName(
			"with transcription with tags"
		)

		VStack {
			Spacer()
			AudioRecordingDetailViewPreview(
				"I am at 123 Main Street. I see a flooded gutter."
			)
		}.previewDisplayName("demo script 1")
	}
}
