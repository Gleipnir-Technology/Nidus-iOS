import Combine
import MapKit
import OSLog
import SwiftData
import SwiftUI

enum ActiveView {
	case audio
	case breadcrumb
	case notes
}
/*
 The root view of the app
 */
struct RootView: View {
	// Stuff I've vetted
	@State private var controller: RootController

	// Stuff I'm not sure about yet
	@State var didSelect: Bool = false
	@State var activeView: ActiveView = .breadcrumb
	@FocusState var isTextFieldFocused: Bool
	@State var location: CLLocation = Initial.location
	@State private var path = NavigationPath()
	@State var resolution = 10
	@State var region: MKCoordinateRegion = Initial.region
	@State private var selection: Int = 0
	@State var selectedCells: [CellSelection] = [CellSelection]()

	init(controller: RootController, isShowingAudioDetail: Bool = false) {
		self.controller = controller
		controller.onInit()
	}

	func breadcrumbCells() -> [H3Cell] {
		let sorted = controller.region.breadcrumb.userPreviousCells.sorted(by: {
			$0.value < $1.value
		})
		return sorted.map { $0.key }
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
		/*if activeView == .breadcrumb {
			activeView = .notes
		}
		else {
			activeView = .breadcrumb
		}*/
	}
	func onMapSelectCell(_ cell: H3Cell) {
		controller.region.breadcrumb.selectedCell = cell
	}
	func onMicButtonLong() {
		didSelect.toggle()
		activeView = .audio
	}
	func onNoteSelected(_ id: UUID) {
		path.removeLast(path.count - 1)
		path.append("note/\(id)")
	}
	func setTabNotes() {
		selection = 0
	}
	var body: some View {
		NavigationStack(path: $path) {
			ZStack {
				VStack {
					switch activeView {
					case .audio:
						AudioDetailView(
							controller: controller.audioRecording
						)
					case .breadcrumb:
						MapViewBreadcrumb(
							breadcrumbCells: breadcrumbCells(),
							initialRegion: controller.region.current,
							notes: controller.notes,
							onSelectCell: onMapSelectCell,
							region: controller.region,
							showsGrid: false
						)
					case .notes:
						NoteListView(
							controller: controller,
							userLocation: controller.region.breadcrumb
								.userCell
						)
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
							activeView == .breadcrumb
								? Color.blue : .secondary
						)
						ButtonAudioRecord(
							audio: controller.audioRecording,
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
				audioRecording: AudioRecordingControllerPreview(
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
