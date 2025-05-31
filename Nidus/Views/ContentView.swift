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
	@State private var selection: Int = 0
	var allNotes: [AnyNote] {
		var fetchDescriptor = FetchDescriptor<ServiceRequest>()
		fetchDescriptor.fetchLimit = 20
		do {
			let serviceRequests = try context.fetch(fetchDescriptor)
			var notes: [AnyNote] = []
			for s in serviceRequests {
				notes.append(AnyNote(s))
			}
			/*
             i = 0
             for t in traps {
             notes.append(AnyNote(t))
             i += 1
             if i > max { break }
             }
             Logger.foreground.info("Have \(traps.count) traps and \(notes.count) notes")
             i = 0
             for s in sources {
             notes.append(AnyNote(s))
             i += 1
             if i > max { break }
             }
             Logger.foreground.info("Have \(sources.count) sources and \(notes.count) notes")
             */
			return notes
		}
		catch {
			Logger.foreground.error("Failed to fetch \(error)")
			return []
		}
	}

	func onNoteSelected(_ note: any Note) {
		path.append(note.id)
	}
	func setTabNotes() {
		selection = 0
	}
	func triggerBackgroundFetch() {
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
	var body: some View {
		NavigationStack(path: $path) {
			TabView(selection: $selection) {
				Tab("Notes", systemImage: "clock", value: 0) {
					NoteListView(
						notes: allNotes,
						userLocation: locationDataManager.location
					)
				}
				Tab("Map", systemImage: "map", value: 1) {
					MapOverview(
						notes: allNotes,
						onNoteSelected: onNoteSelected,
						userLocation: locationDataManager.location
					)
				}
				Tab("Settings", systemImage: "gear", value: 3) {
					SettingView(onSettingsUpdated: triggerBackgroundFetch)
				}
			}
			.navigationDestination(for: UUID.self) { noteId in
				if let note = allNotes.first(where: { $0.id == noteId }) {
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
