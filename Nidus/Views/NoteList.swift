//
//  NoteList.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//
import CoreLocation
import SwiftData
import SwiftUI

struct NoteListView: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Note.content) private var notes: [Note]
	@State private var selectedNote: Note?
	var userLocation: CLLocation?

	var body: some View {
		if notes.count == 0 {
			Text("No notes yet")
		}
		else {
			NoteList(userLocation: userLocation)
		}
	}
}

struct NoteList: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Note.content) private var notes: [Note]
	@State private var selectedNote: Note?
	var userLocation: CLLocation?

	var body: some View {
		List(notes, selection: $selectedNote) { note in
			NavigationLink {
				NoteEditor(note: note, userLocation: userLocation)
			} label: {
				NoteRow(note: note, userLocation: userLocation)
			}
		}
	}
}

#Preview("Empty") {
	ModelContainerPreview(ModelContainer.empty) {
		NoteListView()
	}
}
#Preview("No location") {
	ModelContainerPreview(ModelContainer.sample) {
		NoteListView()
	}
}
#Preview("Sample") {
	ModelContainerPreview(ModelContainer.sample) {
		NoteListView(userLocation: .init(latitude: 33.302, longitude: -111.7328))
	}
}
