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
		NavigationSplitView {
			ZStack {
				if notes.count == 0 {
					Text("No notes yet")
				}
				else {
					NoteList(userLocation: userLocation)
				}
				VStack {
					Spacer()
					HStack {
						Spacer()
						NavigationLink {
							NoteEditor(
								note: nil,
								userLocation: userLocation
							)
						} label: {
							ButtonAddNote()
						}
					}
				}
			}
		} detail: {
			NoteEditor(note: selectedNote)
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
				NoteEditor(note: note)
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
#Preview("Sample") {
	ModelContainerPreview(ModelContainer.sample) {
		NoteListView()
	}
}
