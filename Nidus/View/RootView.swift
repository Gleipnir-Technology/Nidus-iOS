import Combine
import MapKit
import OSLog
import SwiftData
import SwiftUI

/*
 The root view of the app
 */
struct RootView: View {
	@State var didSelect: Bool = false
	@State var isShowingAudioDetail: Bool = false
	@State var isShowingMap: Bool = true
	@FocusState var isTextFieldFocused: Bool
	@State var location: CLLocation = Initial.location
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@Bindable var model: ModelNidus
	var onAppear: (() -> Void)? = nil
	@State private var path = NavigationPath()
	@State var resolution = 10
	@State var region: MKCoordinateRegion = Initial.region
	@State var screenSize: CGSize = .zero
	@State private var selection: Int = 0
	@State var selectedCells: [CellSelection] = [CellSelection]()

	@ViewBuilder
	var notesList: some View {
		if model.notesToShow == nil {
			VStack {
				ProgressView()
				Text("Loading notes up from the local database...")
			}
		}
		else {
			NoteListView(
				currentLocation: CLLocation(
					latitude: model.currentRegion.center
						.latitude,
					longitude: model.currentRegion
						.center
						.longitude
				),
				isTextFieldFocused: $isTextFieldFocused,
				locationDataManager: locationDataManager,
				notes: model.notesToShow!,
				noteBuffer: $model.noteBuffer,
				onDeleteNote: onDeleteNote,
				onFilterAdded: model.onFilterAdded,
				onResetChanges: model.onResetChanges
			)
		}
	}

	func doOnAppear() {
		model.location.subscribe(locationDataManager)
		if onAppear != nil {
			_ = onAppear()
		}
	}
	func onCameraButtonLong() {
		didSelect.toggle()
		print("camera long")
	}
	func onCameraButtonShort() {
		print("camera short")
	}
	func onDeleteNote() {
		model.onDeleteNote()
	}

	func onFilterChange() {
		model.onFilterChange()
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
	func onSaveNoteExisting() {
		isTextFieldFocused = false
		model.onSaveNote(isNew: false)
	}
	func onSaveNoteNew() {
		isTextFieldFocused = false
		model.onSaveNote(isNew: true)
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
							overlayResolution: $model.location
								.resolution,
							region: $region,
							screenSize: $screenSize,
							selectedCell: $model.location
								.selectedLocationH3,
							showsGrid: false,
							showsUserLocation: true,
							userCell: model.location.userLocationH3,
							userPreviousCells: model.location
								.userPreviousLocations.sorted(by: {
									a,
									b in
									return a.value > b.value
								}).map({ element in element.key })
						)
					}
					else {
						notesList
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
							audio: model.audio,
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
					case "map-settings":
						SettingView(
							onSettingsUpdated: model
								.startNoteDownload
						)
					default:
						Text("Unknown destination \(p)")
					}
				}
				if isShowingAudioDetail {
					AudioDetailPane(
						audio: model.audio,
						isShowing: $isShowingAudioDetail
					).frame(maxWidth: .infinity)
						.background(Color.white)
						.cornerRadius(20)
						.shadow(radius: 10)
						.animation(.spring(), value: isShowingAudioDetail)
				}
			}
		}.onAppear {
			doOnAppear()
		}.sensoryFeedback(.selection, trigger: didSelect)
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView(
			model: ModelNidusPreview()
		).previewDisplayName("base")
		RootView(
			isShowingAudioDetail: true,
			model: ModelNidusPreview(
				audio: ModelAudioPreview(
					hasPermissionTranscription: true,
					isRecording: true,
					recordingDuration: 63,
					transcription: "This is some words I pretended to say"
				)
			)
		).previewDisplayName("recording")
	}
}
