//
//  NoteAdd.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/28/25.
//

import CoreLocation
import SwiftData
import SwiftUI

struct NoteAdd: View {
	@State private var content: String
	@State private var category: NoteCategory
	@State private var location: CLLocationCoordinate2D
	@State private var showSavedToast = false
	var onSave: (() -> Void)

	var userLocation: CLLocation?

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	init(onSave: @escaping () -> Void, userLocation: CLLocation?) {
		self.content = ""
		self.category = NoteCategory.info
		self.location =
			userLocation?.coordinate
			?? CLLocationCoordinate2D()
		self.onSave = onSave
	}

	private func save() {
		let newNote = Note(
			category: category,
			content: content,
			location: NoteLocation(location: location)
		)
		modelContext.insert(newNote)
		showSavedToast = true
		onSave()
	}
	var body: some View {
		NavigationView {
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
			}
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Add Note")
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						save()
						dismiss()
					}
				}
			}.toast(message: "Saved", isShowing: $showSavedToast, duration: Toast.short)
		}
	}
}

/*
#Preview("no gps", traits: .modifier(MockDataPreviewModifier())) {
	NoteAdd(userLocation: nil)
}

#Preview("gps", traits: .modifier(MockDataPreviewModifier())) {
	NoteAdd(userLocation: SampleLocations.park)
}
*/
