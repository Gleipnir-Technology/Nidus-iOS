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
	@Environment(\.modelContext) private var context
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@State var currentValue: Float = 0.0
	@State private var path = NavigationPath()
	@Query private var notes: [Note]

	func onNoteSelected(_ note: Note) {
		path.append(note.id)
	}
	var body: some View {
		NavigationStack(path: $path) {
			TabView {
				NoteListView(userLocation: locationDataManager.location).tabItem {
					Label("Notes", systemImage: "clock")
				}
				MapOverview(
					onNoteSelected: onNoteSelected,
					userLocation: locationDataManager.location
				).tabItem {
					Label("Map", systemImage: "map")
				}
				NoteEditor(note: nil, userLocation: locationDataManager.location)
					.tabItem {
						Label("Add", systemImage: "plus.circle")
					}
				SettingView().tabItem {
					Label("Settings", systemImage: "gear")
				}
			}
			.navigationDestination(for: UUID.self) { noteId in
				if let note = notes.first(where: { $0.id == noteId }) {
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
			Task {
				let actor = BackgroundModelActor(
					modelContainer: self.context.container
				)
				do {
					try await actor.triggerFetch()
				}
				catch {
					Logger.background.error(
						"Failed to trigger fetch \(error.localizedDescription)"
					)
				}
			}
		}
	}
}

#Preview("Loading") {
	ContentView().modelContainer(try! ModelContainer.sample())
}
