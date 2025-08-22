//
//  NidusNote.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/26/25.
//

import MapKit
import SwiftUI

class NidusNote: Note {
	/* Note protocol */
	var category: NoteCategory { return .nidus }
	var categoryName: String { return category.name }
	var color: Color { return category.color }
	var content: String { return text }
	var coordinate: CLLocationCoordinate2D {
		get {
			return location.coordinate()
		}
		set {
			location = Location(
				latitude: newValue.latitude,
				longitude: newValue.longitude
			)
		}
	}
	var id: UUID
	var timestamp: Date
	/* end Note protocol */

	var created: Date
	var due: Date?
	var images: [NoteImage]
	var location: Location
	var text: String
	var uploaded: Date?

	init(
		created: Date = Date.now,
		due: Date? = nil,
		images: [NoteImage],
		location: Location,
		text: String,
		uploaded: Date? = nil,
		uuid: UUID = UUID()
	) {
		self.id = uuid
		self.created = created
		self.due = due
		self.images = images
		self.location = location
		self.timestamp = Date.now
		self.text = text
		self.uploaded = uploaded
	}

	static func forPreview(
		images: [NoteImage] = [],
		location: Location = .visalia,
		text: String = "some text"
	) -> NidusNote {
		return NidusNote(
			images: images,
			location: location,
			text: text
		)
	}
	static func == (lhs: NidusNote, rhs: NidusNote) -> Bool {
		return lhs.location == rhs.location
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(location)
	}

	func toPayload() -> NidusNotePayload {
		return NidusNotePayload(
			audio: [],
			images: images.map({ image in
				ImagePayload(
					created: image.created,
					deleted: nil,
					size_x: image.size_x,
					size_y: image.size_y,
					uuid: image.uuid
				)
			}),
			location: location,
			text: text,
			timestamp: timestamp,
			uuid: id
		)
	}
}
