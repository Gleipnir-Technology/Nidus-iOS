import SwiftUI

/// Generic class for showing note detail information - actually routers to specific note-type classes
struct NoteDetailView: View {
	let controller: RootController
	let noteUUID: UUID

	var note: any NoteProtocol {
		controller.notes.model.notes![noteUUID]!
	}
	var body: some View {
		if let source = note as? MosquitoSourceNote {
			MosquitoSourceDetail(
				onFilterAdded: { _ in },
				source: source
			)
		}
		else if let note = note as? AudioNote {
			AudioNoteDetail(
				controller: controller.audioPlayback,
				note: note
			)
		}
		else {
			Text("Unknown Note Detail View")
		}
	}
}
