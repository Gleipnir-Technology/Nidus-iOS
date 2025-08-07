import SwiftUI

/// Generic class for showing note detail information - actually routers to specific note-type classes
struct NoteDetailView: View {
	let controller: NotesController
	let noteUUID: UUID

	var note: any NoteProtocol {
		controller.model.notes![noteUUID]!
	}
	var body: some View {
		if let source = note as? MosquitoSourceNote {
			MosquitoSourceDetail(
				onFilterAdded: { _ in },
				source: source
			)
		}
		else {
			Text("Unknown Note Detail View")
		}
	}
}
