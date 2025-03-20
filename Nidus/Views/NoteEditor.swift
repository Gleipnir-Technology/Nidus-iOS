//
//  NoteEditor.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//
import CoreLocation
import SwiftData
import SwiftUI

struct NoteEditor: View {
	let note: Note?

	@State private var content = ""
	@State private var category: NoteCategory?
	@State private var noteLocation: NoteLocation?
	@State private var userLocation: CLLocationCoordinate2D?

	@Environment(\.dismiss) private var dismiss
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
				location: userLocation == nil
					? nil
					: NoteLocation(
						location: userLocation!
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
				else if let ul = userLocation {
					MapView(coordinate: ul).frame(height: 300)
				}
				else {
					Text("Location unavailable")
				}
				if let category = category {
					Picker(selection: $category) {
						ForEach(categories) { category in
							Label(
								category.name,
								systemImage: category.icon
							)
							.tag(category)
						}
					} label: {
						Text("Category")
					}
				}
				else {
					Text("No categories")
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
			else {
				content = ""
				category = categories.first
			}
		}
	}
}

#Preview("Empty") {
	ModelContainerPreview(ModelContainer.empty) {
		NoteEditor(note: nil)
	}
}

#Preview("Broken", traits: .modifier(MockDataPreviewModifier())) {
	NoteEditor(note: nil)
}
