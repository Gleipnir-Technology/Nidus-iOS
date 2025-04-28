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

	@State private var content: String
	@State private var category: NoteCategory?
	@State private var location: CLLocationCoordinate2D

	var userLocation: CLLocation?

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	@Query(sort: \NoteCategory.name) var categories: [NoteCategory]

	init(note: Note?, userLocation: CLLocation?) {
		self.note = note
		self.content = note?.content ?? ""
		self.category = note?.category
		self.location =
			note?.location.asCLLocationCoordinate2D() ?? userLocation?.coordinate
			?? CLLocationCoordinate2D()
	}

	private var editorTitle: String {
		note == nil ? "Add Note" : "Edit Note"
	}

	private func save() {
		if category == nil {
			fatalError("Must select a category")
		}
		if let note {
			note.category = category!
			note.content = content
			note.location = NoteLocation(location: location)
		}
		else {
			// Add a note
			let newNote = Note(
				category: category!,
				content: content,
				location: NoteLocation(location: location)
			)
			modelContext.insert(newNote)
		}
	}
	var body: some View {
		NavigationStack {
			Form {
				MapView(
					coordinate: $location
				).frame(height: 300)
				Text("Location \(location.latitude), \(location.longitude)")
				/*Picker(selection: $category) {
					ForEach(categories) { c in
						Label(
							c.name,
							systemImage: c.icon
						)
						.tag(Optional(c))
					}
				} label: {
					Text("Category")
				}*/
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
					.disabled(category == nil)
				}
			}
		}
	}
}

#Preview("new no gps", traits: .modifier(MockDataPreviewModifier())) {
	NoteEditor(note: nil, userLocation: nil)
}

#Preview("new gps", traits: .modifier(MockDataPreviewModifier())) {
	NoteEditor(note: nil, userLocation: SampleLocations.park)
}

#Preview("new gps", traits: .modifier(MockDataPreviewModifier())) {
	NoteEditor(note: Note.dog, userLocation: SampleLocations.park)
}
