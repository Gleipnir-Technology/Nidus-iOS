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

	@State private var content = ""
	@State private var category: NoteCategory?
	@State private var location: NoteLocation?

	@Environment(\.dismiss) private var dismiss
	@Environment(LocationDataManager.self) private var locationDataManager
	@Environment(\.modelContext) private var modelContext

	@Query(sort: \NoteCategory.name) var categories: [NoteCategory]

	private var editorTitle: String {
		note == nil ? "Add Note" : "Edit Note"
	}

	private func save() {
		if category == nil {
			fatalError("nil selected category on save()")
		}
		if let note {
			note.content = content
			note.category = category!
		}
		else {
			// Add a note
			let newNote = Note(
				category: category!,
				content: content,
				location: locationDataManager.location?.coordinate == nil
					? nil
					: NoteLocation(
						location: locationDataManager.location!.coordinate
					)
			)
			modelContext.insert(newNote)
		}
	}
	var body: some View {
		NavigationStack {
			Form {
				if let note {
					if let location = note.location {
						MapView(
							coordinate:
								location.asCLLocationCoordinate2D()
						).frame(height: 300)
					}
					else {
						Text("Location unavailable")
					}
				}
				else if let location = locationDataManager.location {
					MapView(coordinate: location.coordinate).frame(height: 300)
				}
				else {
					Text("Location unavailable")
				}
				Picker(selection: $category) {
					ForEach(categories) { category in
						Label(category.name, systemImage: category.icon)
							.tag(category)
					}
				} label: {
					Text("Category")
				}
				TextField("Note content", text: $content, axis: .vertical)
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
					.disabled($category.wrappedValue == nil)
				}
			}
		}.onAppear {
			if let note {
				// Edit the incoming note.
				content = note.content
				category = note.category
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
		NoteEditor(note: .dog)
	}
}
