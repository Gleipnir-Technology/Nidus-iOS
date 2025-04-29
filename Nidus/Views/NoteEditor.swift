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
	@State private var category: NoteCategory
	@State private var location: CLLocationCoordinate2D

	var userLocation: CLLocation?

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	init(note: Note?, userLocation: CLLocation?) {
		self.note = note
		self.content = note?.content ?? ""
		self.category = NoteCategory.byNameOrDefault(note?.categoryName)
		self.location =
			note?.location.asCLLocationCoordinate2D() ?? userLocation?.coordinate
			?? CLLocationCoordinate2D()
	}

	private var editorTitle: String {
		note == nil ? "Add Note" : "Edit Note"
	}

	private func save() {
		if let note {
			note.categoryName = category.name
			note.content = content
			note.location = NoteLocation(location: location)

		}
		else {
			// Add a note
			let newNote = Note(
				category: category,
				content: content,
				location: NoteLocation(location: location)
			)
			modelContext.insert(newNote)
		}
	}
	var body: some View {
		Form {
			MapView(
				coordinate: $location
			).frame(height: 300)
			Text("Location \(location.latitude), \(location.longitude)")
			Picker(selection: $category) {
				ForEach(NoteCategory.all) { c in
					Label(
						c.name,
						systemImage: c.icon
					).tag(c)
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
