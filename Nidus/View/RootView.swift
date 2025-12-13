import Combine
import MapKit
import OSLog
import SwiftData
import SwiftUI

enum ActiveView {
	case audio
	case breadcrumb
	case inspectionSummary
	case route
}
/*
 The root view of the app
 */
struct RootView: View {
	// Stuff I've vetted
	@State private var controller: RootController

	// Stuff I'm not sure about yet
	@State var didSelect: Bool = false
	@State var activeView: ActiveView
	@FocusState var isTextFieldFocused: Bool
	@State var location: CLLocation = Initial.location
	@State private var path = NavigationPath()
	@State var resolution = 10
	@State var region: MKCoordinateRegion = Initial.region
	@State private var selection: Int = 0
	@State var selectedCells: [CellSelection] = [CellSelection]()

	// An indication of the scene's operational state.
	@Environment(\.scenePhase) var scenePhase
	init(activeView: ActiveView = .breadcrumb, controller: RootController) {
		self.activeView = activeView
		self.controller = controller
		controller.onInit()
	}

	func breadcrumbCells() -> [H3Cell] {
		let sorted = controller.region.store.breadcrumb.userPreviousCells.sorted(by: {
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
		if activeView == .breadcrumb {
			path.append("notes-by-area")
		}
		else {
			activeView = .breadcrumb
		}
	}
	func onMapSelectCell(_ cell: H3Cell) {
		controller.ToggleMapCell(cell)
	}
	func onMicButtonLong() {
		didSelect.toggle()
		if activeView == .audio {
			activeView = .breadcrumb
		}
		else {
			activeView = .audio
		}
	}
	func onNoteSelected(_ id: UUID) {
		path.removeLast(path.count - 1)
		path.append("note/\(id)")
	}
	func onRouteButtonLong() {
		activeView = .inspectionSummary
	}
	func onRouteButtonShort() {
		activeView = .route
	}
	func setTabNotes() {
		selection = 0
	}
	var body: some View {
		NavigationStack(path: $path) {
			GeometryReader { geometry in
				ZStack {
					VStack {
						switch activeView {
						case .audio:
							AudioRecordingDetailView(
								controller: controller
							)
						case .breadcrumb:
							RootViewMap(
								breadcrumbCells: breadcrumbCells(),
								controller: controller,
								initialRegion: controller.region
									.store
									.current,
								onSelectCell: onMapSelectCell,
								showsGrid: false
							)
						case .inspectionSummary:
							InspectionSummaryView(
								resident: Resident(
									name: "Bob Marley",
									phone: "420-123-4000",
									email: "bob@marley.com",
									notes: ("Chill dude, fun for a hang")
								),
								visitSource: .trapCount(counts: [
									TrapCount(
										date: Date()
											.addingTimeInterval(
												-21
													* 24
													* 60
													* 60
											),
										count: 5
									),
									TrapCount(
										date: Date()
											.addingTimeInterval(
												-14
													* 24
													* 60
													* 60
											),
										count: 12
									),
									TrapCount(
										date: Date()
											.addingTimeInterval(
												-7
													* 24
													* 60
													* 60
											),
										count: 18
									),
								]),
								timelineEvents: [
									TimelineEvent(
										date: Date()
											.addingTimeInterval(
												-30
													* 24
													* 60
													* 60
											),
										title:
											"Notice Posted",
										description:
											"Notice was posted to the resident's door",
										type: .notice,
										additionalContent:
											.note(
												"Door hanger was left with contact information and explanation of observed standing water in backyard."
											)
									),
									TimelineEvent(
										date: Date()
											.addingTimeInterval(
												-21
													* 24
													* 60
													* 60
											),
										title:
											"Drone Flyover",
										description:
											"A drone flyover was performed of the site",
										type: .droneImage,
										additionalContent:
											.image(
												UIImage(
													systemName:
														"photo"
												)!
											)
									),
									TimelineEvent(
										date: Date()
											.addingTimeInterval(
												-14
													* 24
													* 60
													* 60
											),
										title:
											"Site Treatment",
										description:
											"A tech treated the site with larvicide",
										type: .treatment,
										additionalContent:
											.note(
												"Applied 3oz of Altosid to standing water in unused fountain. Recommended removal of fountain or regular maintenance."
											)
									),
									TimelineEvent(
										date: Date()
											.addingTimeInterval(
												-7
													* 24
													* 60
													* 60
											),
										title:
											"Mosquitofish Confirmation",
										description:
											"Mosquitofish were confirmed present in pond",
										type: .fishPresence,
										additionalContent:
											nil
									),
								],
							)
						case .route:
							RouteListView()
						}
						Spacer()
						HStack {
							ButtonWithLongPress(
								actionLong: onRouteButtonLong,
								actionShort: onRouteButtonShort,
								label: {
									Image(
										systemName:
											"list.clipboard"
									).font(
										.system(
											size: 64,
											weight:
												.regular
										)
									).padding(20)
								}
							).foregroundColor(
								activeView == .route
									? Color.blue : .secondary
							)
							ButtonWithLongPress(
								actionLong: onMapButtonLong,
								actionShort: onMapButtonShort,
								label: {
									Image(systemName: "map")
										.font(
											.system(
												size:
													64,
												weight:
													.regular
											)
										).padding(20)
								}
							).foregroundColor(
								activeView == .breadcrumb
									? Color.blue : .secondary
							)
							ButtonAudioRecord(
								actionLong: onMicButtonLong,
								controller: controller
							)
							ButtonWithLongPress(
								actionLong: onCameraButtonLong,
								actionShort: onCameraButtonShort,
								label: {
									Image(systemName: "camera")
										.font(
											.system(
												size:
													64,
												weight:
													.regular
											)
										).padding(20)
								}
							).foregroundColor(.secondary)
						}
					}.navigationDestination(for: String.self) { p in
						switch p {
						case "camera":
							CameraView(camera: controller.camera)
								.preferredColorScheme(.dark)
								.statusBarHidden(true)
								.task {
									// Start the capture pipeline.
									await controller.camera
										.start()
								}
								// Monitor the scene phase. Synchronize the persisetent state when
								// the camera is running and the app becomes active.
								.onChange(of: scenePhase) {
									_,
									newPhase in
									guard
										controller.camera
											.status
											== .running,
										newPhase == .active
									else { return }
									Task { @MainActor in
										await controller
											.camera
											.syncState()
									}
								}
						case "map-settings":
							SettingView(controller: controller)
						default:
							if p.starts(with: "notes-by-area") {
								NoteListView(
									controller: controller,
									selectedCell: controller
										.region
										.store.breadcrumb
										.selectedCell,
									userLocation: controller
										.region
										.store
										.breadcrumb
										.userCell
								)
							}
							else if p.starts(with: "notes-by-cell/") {
								let cellString: String = String(
									p.split(separator: "/")
										.last!
								)
								let cell: UInt64 = UInt64(
									cellString
								)!
								NoteListView(
									controller: controller,
									selectedCell: cell,
									userLocation: controller
										.region.store
										.breadcrumb.userCell
								)
							}
							else {
								Text("Unknown destination \(p)")
							}
						}
					}
					if activeView == .breadcrumb {
						MapLayerSelector(
							onOverlaySelectionChange: controller.region
								.onOverlaySelectionChanged
						).padding()
							.position(
								x: geometry.size.width - 370,
								y: geometry.size.height - 140
							)
					}
					NetworkStatusView(
						progress: controller.network
							.backgroundNetworkProgress,
						state: controller.network.backgroundNetworkState
					).padding()
						.position(
							x: geometry.size.width - 32,
							y: geometry.size.height - 140
						)
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
					AudioRecordingStore(
						hasPermissionTranscription: true,
						isRecording: true,
						recordingDuration: 63,
						transcription:
							"This is some words I pretended to say"
					)
				)
			)
		).previewDisplayName("recording")
		RootView(
			activeView: .audio,
			controller: RootControllerPreview(
				audioRecording: AudioRecordingControllerPreview(
					AudioRecordingStore(
						hasPermissionTranscription: true,
						isRecording: true,
						recordingDuration: 63,
						transcription:
							"This is some words I pretended to say"
					)
				)
			)
		).previewDisplayName("recording detail view")
		RootView(

			controller: RootControllerPreview(
				network: NetworkControllerPreview(
					backgroundNetworkProgress: 0.33,
					backgroundNetworkState: .downloading
				)
			)
		).previewDisplayName("downloading")
	}
}
