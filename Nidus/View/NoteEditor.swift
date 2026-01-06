import CoreLocation
import H3
import OSLog
import SwiftData
import SwiftUI

struct NoteEditor: View {
	var currentLocation: CLLocation?
	let note: any Note

	@State private var content: String
	@State private var category: NoteCategory
	@State private var h3cell: H3Cell
	@State private var location: CLLocation?
	@State private var showSavedToast = false

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	init(currentLocation: CLLocation?, note: any Note) {
		self.note = note
		self.content = note.content
		self.category = NoteCategory.byNameOrDefault(note.categoryName)
		self.h3cell = note.h3cell
		do {
			let l = try cellToLatLng(cell: h3cell)
			self.location = CLLocation(
				latitude: l.latitude,
				longitude: l.longitude
			)
		}
		catch {
			self.location = nil
		}
	}

	private func save() {
		/*
         note.categoryName = category.name
		note.content = content
		note.location = NoteLocation(location: location)
         */
		showSavedToast = true
	}

	var locationDescription: String {
		do {
			let location = try cellToLatLng(cell: h3cell)
			return "\(location.latitude), \(location.longitude)"
		}
		catch {
			Logger.background.error("Failed to convert H3Cell to CLLocation: \(error)")
			return "err"
		}
	}

	var body: some View {
		Form {
			LocationView(
				location: $location
			).frame(height: 300)
			Text(
				locationDescription
			)
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
		currentLocation: nil,
		note: ServiceRequest(
			address: "somewhere",
			assignedTechnician: "Dude Guy",
			city: "over there",
			created: Date.now,
			h3cell: .visalia,
			hasDog: false,
			hasSpanishSpeaker: false,
			id: UUID(uuidString: "1846d421-f8ab-4e37-850a-b61bb8422453")!,
			priority: "low",
			source: "everywhere",
			status: "bad",
			target: "here",
			zip: "12345"
		)
	)
}
