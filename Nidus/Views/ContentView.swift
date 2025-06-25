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

struct ContentView: View {
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@State var currentValue: Float = 0.0
	@State private var path = NavigationPath()
	@State private var selection: Int = 0
	@Bindable var model: NidusModel
	var onAppear: () -> Void

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
						AddNoteView(
							location: CLLocation(
								latitude: -39,
								longitude: -111
							),
							locationDataManager: locationDataManager
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
							notes: model.notesToShow,
							onFilterAdded: model.onFilterAdded
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
						value: 4
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
						value: 5
					) {
						SettingView(
							onSettingsUpdated: model
								.triggerBackgroundFetch
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
						Text("NOAAAAA")
					}
				}
				switch model.backgroundNetworkState {
				case .downloading:
					ProgressView(
						"Downloading data",
						value: model.backgroundNetworkProgress
					).frame(maxWidth: 300)
				case .error:
					Text("Error downloading data: \(model.errorMessage ?? "")")
				case .idle:
					EmptyView()
				case .loggingIn:
					Text("Logging in...")
				case .notConfigured:
					Text("Configure sync in settings")
				case .savingData:
					ProgressView(
						"Saving data",
						value: model.backgroundNetworkProgress
					).frame(maxWidth: 300)
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
