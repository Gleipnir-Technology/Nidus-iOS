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
			VStack {
				if isShowingMap {
					MapViewBreadcrumb(
						overlayResolution: $model.location.resolution,
						region: $region,
						screenSize: $screenSize,
						selectedCell: $model.location.selectedLocationH3,
						showsGrid: false,
						showsUserLocation: true,
						userCell: model.location.userLocationH3,
						userPreviousCells: model.location
							.userPreviousLocations.sorted(by: { a, b in
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
								.system(size: 64, weight: .regular)
							).padding(20)
						}
					).foregroundColor(isShowingMap ? Color.blue : .secondary)
					ButtonAudioRecord(
						audio: model.audioRecorder,
						didSelect: $didSelect
					)
					ButtonWithLongPress(
						actionLong: onCameraButtonLong,
						actionShort: onCameraButtonShort,
						label: {
							Image(systemName: "camera").font(
								.system(size: 64, weight: .regular)
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
		}.onAppear {
			doOnAppear()
		}.sensoryFeedback(.selection, trigger: didSelect)
	}
}

#Preview("No notes, no settings") {
	RootView(
		model: NidusModelPreview()
	)
}

#Preview("Downloading") {
	RootView(
		model: NidusModelPreview(
			backgroundNetworkProgress: 0.5,
			backgroundNetworkState: .downloading
		)
	)
}

#Preview("Error") {
	RootView(
		model: NidusModelPreview(
			backgroundNetworkProgress: 0.0,
			backgroundNetworkState: .error,
			errorMessage: "something bad"
		)
	)
}

#Preview("Saving") {
	RootView(
		model: NidusModelPreview(
			backgroundNetworkProgress: 0.3,
			backgroundNetworkState: .savingData
		)
	)
}

#Preview("Has notes") {
	RootView(
		model: NidusModelPreview(
			notesToShow: AnyNote.previewListShort
		)
	)
}

#Preview("Movement history") {
	RootView(model: NidusModelPreview())
}
