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

struct MainStatusView: View {
	var backgroundNetworkState: BackgroundNetworkState
	var backgroundNetworkProgress: Double
	var errorMessage: String?

	var body: some View {
		switch backgroundNetworkState {
		case .downloading:
			ProgressView(
				"Downloading data",
				value: backgroundNetworkProgress
			).frame(maxWidth: 300)
		case .error:
			Text("Error downloading data: \(errorMessage ?? "")")
		case .idle:
			EmptyView()
		case .loggingIn:
			Text("Logging in...")
		case .notConfigured:
			Text("Configure sync in settings")
		case .savingData:
			ProgressView(
				"Saving data",
				value: backgroundNetworkProgress
			).frame(maxWidth: 300)
		case .uploadingChanges:
			ProgressView(
				"Uploading",
				value: backgroundNetworkProgress
			).frame(maxWidth: 300)
		}
	}
}

struct ContentView: View {
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@State var currentValue: Float = 0.0
	@State private var path = NavigationPath()
	@State private var selection: Int = 0
	@Bindable var model: NidusModel
	var onAppear: () -> Void

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

	func onFilterChange() {
		model.onFilterChange()
	}
	func onNoteSelected(_ note: any Note) {
		path.append(note.id)
	}
	func setTabNotes() {
		selection = 0
	}
	var body: some View {
		NavigationStack(path: $path) {
			VStack {
				TabView(selection: $selection) {
					Tab("Create", systemImage: "plus", value: 0) {
						EditNidusNoteView(
							locationDataManager: locationDataManager,
							note: nil,
							onSave: model.onSaveNote
						)
					}
					Tab("Notes", systemImage: "clock", value: 1) {
						NoteListView(
							currentLocation: CLLocation(
								latitude: model.currentRegion.center
									.latitude,
								longitude: model.currentRegion
									.center
									.longitude
							),
							locationDataManager: locationDataManager,
							notes: model.notesToShow,
							onFilterAdded: model.onFilterAdded,
							onNoteSave: model.onSaveNote
						)
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
						FilterView(
							filterInstances: $model.filterInstances,
							notesCountFiltered: model.notes.count
								- model.notesToShow.count,
							notesCountTotal: model.notes.count,
							onFilterChange: onFilterChange
						)
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
					if let note = model.notesToShow.first(where: {
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
				ToolbarItem {
					Button {
						Logger.foreground.log("Save button tapped")
					} label: {
						Text("Save")
					}
				}
			}
		}.onAppear {
			onAppear()
		}
	}
}

#Preview("No notes, no settings") {
	ContentView(
		model: NidusModelPreview(),
		onAppear: {}
	)
}

#Preview("Downloading") {
	ContentView(
		model: NidusModelPreview(
			backgroundNetworkProgress: 0.5,
			backgroundNetworkState: .downloading
		),
		onAppear: {}
	)
}

#Preview("Error") {
	ContentView(
		model: NidusModelPreview(
			backgroundNetworkProgress: 0.0,
			backgroundNetworkState: .error,
			errorMessage: "something bad"
		),
		onAppear: {}
	)
}

#Preview("Saving") {
	ContentView(
		model: NidusModelPreview(
			backgroundNetworkProgress: 0.3,
			backgroundNetworkState: .savingData
		),
		onAppear: {}
	)
}

#Preview("Has notes") {
	ContentView(
		model: NidusModelPreview(
			notesToShow: AnyNote.previewListShort
		),
		onAppear: {}
	)
}
