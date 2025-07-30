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

	var navTitle: String {
		switch selection {
		case 0:
			return "Create Note"
		case 1:
			return "Notes"
		case 2:
			return "Map"
		case 3:
			return "Filters"
		case 4:
			return "Settings"
		default:
			return "Unknown Tab"
		}
	}

	@ToolbarContentBuilder
	func toolbarByTab() -> some ToolbarContent {
		switch selection {
		case 0:
			ToolbarItem {
				Button {
					onSaveNoteNew()
				} label: {
					Text("Save").disabled(model.notes == nil)
				}
			}
		case 1:
			ToolbarItem {
				Menu("Sorting") {
					Text("Sort by...")
					Button("Distance") {
						Logger.foreground.info("sort by distance")
					}
					Button("Tag") {
						Logger.foreground.info("sort by tag")
					}
				}
			}

		default:
			ToolbarItem { EmptyView() }
		}
	}

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

	func onCameraButton() {
		print("camera")
	}
	func onDeleteNote() {
		model.onDeleteNote()
	}

	func onFilterChange() {
		model.onFilterChange()
	}
	func onMapButton() {
		print("map!")
	}
	func onMicButton() {
		print("mic!")
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
		VStack {
			MapViewBreadcrumb(
				location: $location,
				region: $region,
				screenSize: $screenSize
			)
			HStack {
				Button(
					action: onMapButton,
					label: {
						Image(systemName: "map").font(
							.system(size: 64, weight: .regular)
						).padding(20)
					}
				).foregroundColor(.secondary)
				Button(
					action: onMicButton,
					label: {
						Image(systemName: "microphone").font(
							.system(size: 64, weight: .regular)
						).padding(20)
					}
				).foregroundColor(.secondary)
				Button(
					action: onCameraButton,
					label: {
						Image(systemName: "camera").font(
							.system(size: 64, weight: .regular)
						).padding(20)
					}
				).foregroundColor(.secondary)
			}
		}
	}
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
			.navigationTitle(navTitle)
			.toolbar {
				toolbarByTab()
			}
		}.onAppear {
			_ = onAppear()
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
