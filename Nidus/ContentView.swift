//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
	@Query(sort: [SortDescriptor(\Note.title)]) var notes: [Note]
	@Environment(\.modelContext) var context
	@State private var selectedNote: Note?

	var body: some View {
		NavigationSplitView {
			ZStack {
				if notes.count == 0 {
					Text("No notes yet")
				}
				else {
					NoteList(notes: notes, selectedNote: $selectedNote)
				}
				VStack {
					Spacer()
					HStack {
						Spacer()
						NavigationLink {
							NoteEditor(note: nil)
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

#Preview("Loading") {
	let preview = Preview()
	preview.addExamples(Note.sampleNotes)
	return ContentView().modelContainer(preview.modelContainer)
}
