//
//  NoteEditor.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//
import SwiftData
import SwiftUI

struct NoteEditor: View {
	let note: Note?

	@State private var title = ""
	@State private var selectedCategory: NoteCategory?

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext
	@Environment(NavigationContext.self) private var navigationContext

	@Query(sort: \NoteCategory.name) var categories: [NoteCategory]

	private var editorTitle: String {
		note == nil ? "Add Note" : "Edit Note"
	}

	private func save() {
		if selectedCategory == nil {
			fatalError("nil selected category on save()")
		}
		if let note {
			note.title = title
			note.category = selectedCategory!
		}
		else {
			// Add a note
			let newNote = Note(title: title, category: selectedCategory!)
			modelContext.insert(newNote)
		}
	}
	var body: some View {
		NavigationStack {
			Form {
				TextField("Title", text: $title)
				if let unwrapped = Binding($selectedCategory) {
					CategorySelectorView(selectedCategory: unwrapped)
				}
			}.toolbar {
				ToolbarItem(placement: .principal) {
					Text(editorTitle)
				}

				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						withAnimation {
							save()
							dismiss()
						}
					}
					// Require a Category to save changes
					.disabled($selectedCategory.wrappedValue == nil)
				}
			}
		}.onAppear {
			if let note {
				// Edit the incoming note.
				selectedCategory = note.category
				title = note.title
			}
		}
	}
}

#Preview("Add note") {
	ModelContainerPreview(ModelContainer.sample) {
		NoteEditor(note: nil)
	}
}

#Preview("Edit note") {
	ModelContainerPreview(ModelContainer.sample) {
		NoteEditor(note: .gate)
	}
}
