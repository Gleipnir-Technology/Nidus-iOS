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
	let note: any Note

	@State private var content: String
	@State private var category: NoteCategory
	@State private var location: CLLocationCoordinate2D
	@State private var showSavedToast = false

	var userLocation: CLLocation?

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	init(note: any Note, userLocation: CLLocation?) {
		self.note = note
		self.content = note.content
		self.category = NoteCategory.byNameOrDefault(note.categoryName)
		self.location = note.coordinate
	}

	private func save() {
		/*
         note.categoryName = category.name
		note.content = content
		note.location = NoteLocation(location: location)
         */
		showSavedToast = true
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
				Text("Edit Note")
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Save") {
					save()
				}
			}
		}.toast(message: "Saved", isShowing: $showSavedToast, duration: Toast.short)
	}
}

#Preview {
	NoteEditor(
		note: ServiceRequest(
			address: "somewhere",
			city: "over there",
			created: Date.now,
			id: UUID(uuidString: "1846d421-f8ab-4e37-850a-b61bb8422453")!,
			location: Location(latitude: 30, longitude: -111),
			priority: "low",
			source: "everywhere",
			status: "bad",
			target: "here",
			zip: "12345"
		),
		userLocation: nil
	)
}
