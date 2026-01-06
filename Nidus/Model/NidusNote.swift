import MapKit
import SwiftUI

class NidusNote: Note {
	/* Note protocol */
	var category: NoteCategory { return .nidus }
	var categoryName: String { return category.name }
	var color: Color { return category.color }
	var content: String { return text }
	var h3cell: H3Cell
	var id: UUID
	var timestamp: Date
	/* end Note protocol */

	var created: Date
	var due: Date?
	var images: [NoteImage]
	var text: String
	var uploaded: Date?

	init(
		created: Date = Date.now,
		due: Date? = nil,
		h3cell: H3Cell,
		images: [NoteImage],
		text: String,
		uploaded: Date? = nil,
		uuid: UUID = UUID()
	) {
		self.id = uuid
		self.created = created
		self.due = due
		self.h3cell = h3cell
		self.images = images
		self.timestamp = Date.now
		self.text = text
		self.uploaded = uploaded
	}

	static func forPreview(
		h3cell: H3Cell = .visalia,
		images: [NoteImage] = [],
		text: String = "some text"
	) -> NidusNote {
		return NidusNote(
			h3cell: h3cell,
			images: images,
			text: text
		)
	}
	static func == (lhs: NidusNote, rhs: NidusNote) -> Bool {
		return lhs.h3cell == rhs.h3cell
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(h3cell)
	}

	func toPayload() -> NidusNotePayload {
		return NidusNotePayload(
			audio: [],
			h3cell: h3cell,
			images: images.map({ image in
				ImagePayload(
					created: image.created,
					deleted: nil,
					size_x: image.size_x,
					size_y: image.size_y,
					uuid: image.uuid
				)
			}),
			text: text,
			timestamp: timestamp,
			uuid: id
		)
	}
}
