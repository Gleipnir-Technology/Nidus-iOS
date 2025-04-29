//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var context
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@State var currentValue: Float = 0.0

	func onNoteSelected(_ note: Note) {
		print(note.content)
	}
	var body: some View {
		NavigationStack {
			NavigationLink {
				NoteEditor(note: nil, userLocation: locationDataManager.location)
			} label: {
				Text("Add Note")
			}
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
			}
		}
	}
}

#Preview("Loading") {
	ContentView().modelContainer(try! ModelContainer.sample())
}
