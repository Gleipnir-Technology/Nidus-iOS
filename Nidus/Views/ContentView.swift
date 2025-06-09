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
	var model: NidusModel
	var onAppear: () -> Void
	var onMapPositionChange: (MKCoordinateRegion) -> Void

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
					Tab("Notes", systemImage: "clock", value: 0) {
						NoteListView(
							currentLocation: CLLocation(
								latitude: model.currentRegion.center
									.latitude,
								longitude: model.currentRegion
									.center
									.longitude
							),
							notes: model.notesToShow
						)
					}
					Tab("Map", systemImage: "map", value: 1) {
						MapOverview(
							dataSource: model.cluster,
							onNoteSelected: onNoteSelected,
							onPositionChange: onMapPositionChange,
							userLocation: locationDataManager.location
						)
					}
					Tab("Settings", systemImage: "gear", value: 3) {
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
					Text("Downloading data...")
				case .error:
					Text("Error downloading data")
				case .idle:
					EmptyView()
				case .loggingIn:
					Text("Logging in...")
				case .notConfigured:
					Text("Configure sync in settings")
				case .savingData:
					Text("Saving data...")
				}
			}
		}.onAppear {
			onAppear()
		}
	}
}

#Preview("No notes") {
	ContentView(
		model: NidusModelPreview(),
		onAppear: {},
		onMapPositionChange: { (MKCoordinateRegion) -> Void in
		}
	)
}

#Preview("Downloading") {
	ContentView(
		model: NidusModelPreview(backgroundNetworkState: .downloading),
		onAppear: {},
		onMapPositionChange: { (MKCoordinateRegion) -> Void in
		}
	)
}
