//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//
import Combine
import MapKit
import OSLog
import SwiftData
import SwiftUI

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
	func onMicButtonShort() {
		print("mic short!")
	}
	func onMicButtonLong() {
		print("mic long!")
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
						location: $location,
						region: $region,
						screenSize: $screenSize,
						showsUserLocation: true
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
					ButtonWithLongPress(
						actionLong: onMicButtonLong,
						actionShort: onMicButtonShort,
						label: {
							Image(systemName: "microphone").font(
								.system(size: 64, weight: .regular)
							).padding(20)
						}
					).foregroundColor(.secondary)
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
			}
		}.onAppear {
			doOnAppear()
		}.navigationDestination(for: String.self) { p in
			Text("String detail \(p)")
		}
	}
	/*
	var body2: some View {
		NavigationStack(path: $path) {
			VStack {
				TabView(selection: $selection) {
					Tab("Create", systemImage: "plus", value: 0) {
						EditNidusNoteView(
							isTextFieldFocused: $isTextFieldFocused,
							locationDataManager: model
								.locationDataManager,
							note: nil,
							noteBuffer: $model.noteBuffer,
							onDeleteNote: model.onDeleteNote,
							onResetChanges: model.onResetChanges
						)
					}
					Tab("Notes", systemImage: "clock", value: 1) {
						notesList
					}
					Tab("Map", systemImage: "map", value: 2) {
						MapOverview(
							model: model,
							onNoteSelected: onNoteSelected,
							userLocation: locationDataManager.location
						)
					}
					Tab(
						"Filters",
						systemImage: "line.3.horizontal.decrease",
						value: 3
					) {
						if model.notes == nil || model.notesToShow == nil {
							ProgressView()
						}
						else {
							FilterView(
								filterInstances: $model
									.filterInstances,
								notesCountFiltered: model.notes!
									.count
									- model.notesToShow!.count,
								notesCountTotal: model.notes!.count,
								onFilterChange: onFilterChange
							)
						}
					}
					Tab(
						"Sync",
						systemImage: "gear",
						value: 4
					) {
						SettingView(
							onSettingsUpdated: model
								.startNoteDownload
						)
					}
				}
				.navigationDestination(for: UUID.self) { noteId in
					if let note = model.notesToShow!.first(where: {
						$0.id == noteId
					}) {
						NoteEditor(
							currentLocation: locationDataManager
								.location,
							note: note
						)
					}
					else {
						Text("There is no note with UUID \(noteId)")
					}
				}
				MainStatusView(
					backgroundNetworkState: model.backgroundNetworkState,
					backgroundNetworkProgress: model.backgroundNetworkProgress,
					errorMessage: model.errorMessage
				)
			}
			.navigationBarTitleDisplayMode(.inline)
		}.toast(
			message: "Need a location first",
			isShowing: $model.toast.showLocationToast,
			duration: Toast.short
		).toast(
			message: "Note saved.",
			isShowing: $model.toast.showSavedToast,
			duration: Toast.short
		).toast(
			message: "Failed to save note, tell a developer",
			isShowing: $model.toast.showSavedErrorToast,
			duration: Toast.long
		)
	}
     */
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
