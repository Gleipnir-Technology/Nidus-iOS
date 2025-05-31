//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//
import OSLog
import SwiftData
import SwiftUI

struct ContentView: View {
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@State var currentValue: Float = 0.0
	@State private var path = NavigationPath()
	@State private var selection: Int = 0
	var db: Database

	func onNoteSelected(_ note: any Note) {
		path.append(note.id)
	}
	func setTabNotes() {
		selection = 0
	}
	func triggerBackgroundFetch() {
		Task {
			let actor = BackgroundModelActor()
			do {
				try await actor.triggerFetch(db)
			}
			catch {
				Logger.background.error(
					"Failed to trigger fetch \(error.localizedDescription)"
				)
			}
		}
	}
	var body: some View {
		NavigationStack(path: $path) {
			TabView(selection: $selection) {
				Tab("Notes", systemImage: "clock", value: 0) {
					NoteListView(
						notes: db.notesToShow,
						userLocation: locationDataManager.location
					)
				}
				Tab("Map", systemImage: "map", value: 1) {
					MapOverview(
						notes: db.notesToShow,
						onNoteSelected: onNoteSelected,
						userLocation: locationDataManager.location
					)
				}
				Tab("Settings", systemImage: "gear", value: 3) {
					SettingView(onSettingsUpdated: triggerBackgroundFetch)
				}
			}
			.navigationDestination(for: UUID.self) { noteId in
				if let note = db.notesToShow.first(where: { $0.id == noteId }) {
					NoteEditor(
						note: note,
						userLocation: locationDataManager.location
					)
				}
				else {
					Text("NOAAAAA")
				}
			}
		}.onAppear {
			triggerBackgroundFetch()
		}
	}
}
