import Combine
import MapKit
import OSLog
import SwiftData
import SwiftUI

/*
 The root view of the app
 */
struct RootView: View {
	// Stuff I've vetted
	@State private var controller: RootController

	// Stuff I'm not sure about yet
	@State var didSelect: Bool = false
	@State var isShowingAudioDetail: Bool
	@State var isShowingMap: Bool = true
	@FocusState var isTextFieldFocused: Bool
	@State var location: CLLocation = Initial.location
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@State private var path = NavigationPath()
	@State var resolution = 10
	@State var region: MKCoordinateRegion = Initial.region
	@State private var selection: Int = 0
	@State var selectedCells: [CellSelection] = [CellSelection]()

	init(controller: RootController, isShowingAudioDetail: Bool = false) {
		self.controller = controller
		self.isShowingAudioDetail = isShowingAudioDetail
	}

	func onCameraButtonLong() {
		didSelect.toggle()
		print("camera long")
	}
	func onCameraButtonShort() {
		path.append("camera")
	}

	func onMapButtonLong() {
		didSelect.toggle()
		path.append("map-settings")
	}
	func onMapButtonShort() {
		isShowingMap.toggle()
	}
	func onMicButtonLong() {
		didSelect.toggle()
		isShowingAudioDetail.toggle()
	}
	func onNoteSelected(_ note: any Note) {
		path.append(note.id)
	}
	func setTabNotes() {
		selection = 0
	}
	var body: some View {
		NavigationStack(path: $path) {
			ZStack {
				VStack {
					if isShowingMap {
						MapViewBreadcrumb(
							controller: controller.region,
							showsGrid: false
						)
					}
					else {
						NoteListView(controller: controller.notes)
					}
					Spacer()
					HStack {
						ButtonWithLongPress(
							actionLong: onMapButtonLong,
							actionShort: onMapButtonShort,
							label: {
								Image(systemName: "map").font(
									.system(
										size: 64,
										weight: .regular
									)
								).padding(20)
							}
						).foregroundColor(
							isShowingMap ? Color.blue : .secondary
						)
						ButtonAudioRecord(
							audio: controller.audio,
							actionLong: onMicButtonLong
						)
						ButtonWithLongPress(
							actionLong: onCameraButtonLong,
							actionShort: onCameraButtonShort,
							label: {
								Image(systemName: "camera").font(
									.system(
										size: 64,
										weight: .regular
									)
								).padding(20)
							}
						).foregroundColor(.secondary)
					}
				}.navigationDestination(for: String.self) { p in
					switch p {
					case "camera":
						CameraView(
							controller: controller.camera,
							toDismiss: {
								path.removeLast()
							}
						)
					case "map-settings":
						SettingView(controller: controller)
					default:
						Text("Unknown destination \(p)")
					}
				}
				if isShowingAudioDetail {
					AudioDetailPane(
						controller: controller.audio,
						isShowing: $isShowingAudioDetail
					).frame(maxWidth: .infinity)
						.background(Color.white)
						.cornerRadius(20)
						.shadow(radius: 10)
						.animation(.spring(), value: isShowingAudioDetail)
				}
			}
		}.onAppear {
			controller.onAppear()
		}.sensoryFeedback(.selection, trigger: didSelect)
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView(controller: RootControllerPreview()).previewDisplayName("base")
		RootView(
			controller: RootControllerPreview(
				audio: AudioControllerPreview(
					hasPermissionTranscription: true,
					model: AudioModel(
						isRecording: true,
						recordingDuration: 63,
						transcription:
							"This is some words I pretended to say"
					)
				)
			),
			isShowingAudioDetail: true
		).previewDisplayName("recording")
	}
}
