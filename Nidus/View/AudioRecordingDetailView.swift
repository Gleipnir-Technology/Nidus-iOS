import SwiftUI

struct AudioRecordingDetailView: View {
	let controller: AudioRecordingController

	private func timeString(_ timeInterval: TimeInterval) -> String {
		let minutes = Int(timeInterval) / 60
		let seconds = Int(timeInterval) % 60
		return String(format: "%d:%02d", minutes, seconds)
	}

	var body: some View {
		VStack(alignment: .center, spacing: 20) {
			if controller.store.isRecording {
				VStack(alignment: .leading, spacing: 10) {
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
				Text("Press the record button below to begin recording").frame(
					maxWidth: .infinity,
					alignment: .center
				)
			}
		}.navigationTitle(navigationTitle).navigationBarTitleDisplayMode(.inline)
	}

	var navigationTitle: String {
		if controller.store.isRecording {
			return "Recording - \(timeString(controller.store.recordingDuration))"
		}
		return "Not Recording"
	}
}

struct AudioRecordingDetailViewPreview: View {
	var transcription: String
	var isRecording: Bool
	var knowledgeGraph: KnowledgeGraph?
	var recordingDuration: TimeInterval

	init(_ transcription: String, isRecording: Bool = true, recordingDuration: TimeInterval = 0)
	{
		self.transcription = transcription
		self.isRecording = isRecording
		self.knowledgeGraph = ExtractKnowledge(transcription)
		self.recordingDuration = recordingDuration
	}

	var body: some View {
		// This is duplicated from RootView to ensure the previews are nested correctly
		NavigationStack {
			GeometryReader { geometry in
				VStack {
					AudioRecordingDetailView(
						controller: AudioRecordingControllerPreview(
							AudioRecordingStore(
								hasPermissionTranscription: true,
								isRecording: isRecording,
								knowledgeGraph: knowledgeGraph,
								recordingDuration:
									recordingDuration,
								transcription: transcription
							)
						)
					)
				}
			}
		}
	}
}

struct AudioDetailView_Previews: PreviewProvider {
	static var previews: some View {
		AudioRecordingDetailViewPreview("", isRecording: false)
			.previewDisplayName("Not recording")

		AudioRecordingDetailViewPreview(
			"",
			isRecording: true,
			recordingDuration: 60 * 2 + 15
		)
		.previewDisplayName("recording")

		AudioRecordingDetailViewPreview(
			"This is a test transcription",
			isRecording: true,
			recordingDuration: 60 * 2 + 15
		).previewDisplayName("transcription sans tags")

		AudioRecordingDetailViewPreview(
			"Checking orchards at Avenue 300 and Road 140. 92 degrees, full sun. Rows five through nine have deep ruts still wet from last week’s flood irrigation. Soil is clay-heavy, tractor ruts holding water. Orchard is mature citrus. Took five dips, each with between twenty and a hundred larvae, mostly third and fourth instar Culex. Treated rut areas with one pound of VectoMax FG. Spoke with Jim, the foreman who manages the site. Told him the ruts are producing mosquitoes — he said he’ll have someone grade them before the next irrigation in two weeks. Gave me his number 559-555-5555 and said to call if anything comes up. Need to check back in two weeks to confirm the issue’s resolved."
		).previewDisplayName(
			"transcription nidus"
		)

		AudioRecordingDetailViewPreview(
			"Checking on a mosquito source at 123 Main Street. 10 dips. 20 pupae. 30 larvae. 40 eggs. second instar. Looks like it may be Culex."
		).previewDisplayName("transcription FS source incomplete")
		AudioRecordingDetailViewPreview(
			"Checking on a mosquito source at 123 Main Street. 10 dips. 20 pupae. 40 eggs. second instar."
		).previewDisplayName("transcription FS source incomplete")
	}
}
