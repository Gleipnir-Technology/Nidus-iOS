//
//  NoteList.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//
import SwiftData
import SwiftUI

struct NoteListView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(NavigationContext.self) private var navigationContext
	@Query(sort: \Note.title) private var notes: [Note]
	var body: some View {
		NavigationSplitView {
			ZStack {
				if notes.count == 0 {
					Text("No notes yet")
				}
				else {
					NoteList()
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
			NoteEditor(note: navigationContext.selectedNote)
		}
	}
}

struct NoteList: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(NavigationContext.self) private var navigationContext
	@Query(sort: \Note.title) private var notes: [Note]

	var body: some View {
		@Bindable var navigationContext = navigationContext
		if notes.count == 0 {
			Text("No notes yet")
		}
		else {
			List(notes, selection: $navigationContext.selectedNote) { note in
				NavigationLink {
					NoteEditor(note: note)
				} label: {
					NoteRow(note: note)
				}
			}
		}
	}
}

#Preview {
	ModelContainerPreview(ModelContainer.sample) {
		NavigationStack {
			NoteList().environment(NavigationContext())
		}
	}
}
