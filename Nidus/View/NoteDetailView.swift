import SwiftUI

/// Generic class for showing note detail information - actually routers to specific note-type classes
struct NoteDetailView: View {
	let controller: RootController
	let noteUUID: UUID
	let note: (any NoteProtocol)?

	init(controller: RootController, noteUUID: UUID) {
		self.controller = controller
		self.noteUUID = noteUUID
		self.note = controller.notes.store.notes![noteUUID]
	}
	var body: some View {
		if note == nil {
			Text("Loading...")
		}
		else if let source = note as? MosquitoSourceNote {
			MosquitoSourceDetail(
				onFilterAdded: { _ in },
				source: source
			)
		}
		else if let note = note as? AudioNote {
			AudioNoteDetail(
				controller: controller,
				note: note
			)
		}
		else if let note = note as? PictureNote {
			PictureNoteDetail(
				note: note
			)
		}
		else if let note = note as? ServiceRequestNote {
			ServiceNoteDetail(
				onFilterAdded: { _ in },
				request: note
			)
		}
		else {
			Text("Unknown Note Detail View")
		}
	}
}
