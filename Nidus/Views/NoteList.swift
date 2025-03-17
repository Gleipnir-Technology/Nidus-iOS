//
//  NoteList.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI

struct NoteList: View {
	let notes: [Note]
	@Binding var selectedNote: Note?

	var body: some View {
		if notes.count == 0 {
			Text("No notes yet")
		}
		else {
			List(notes, selection: $selectedNote) { note in
				NavigationLink {
					NoteDetail(note: note)
				} label: {
					NoteRow(note: note)
				}
			}
		}
	}
}

#Preview {
	let preview = Preview()
	preview.addExamples(Note.sampleNotes)
	return ContentView().modelContainer(preview.modelContainer)
}
