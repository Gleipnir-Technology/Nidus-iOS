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

	var audioRecordings: [AudioRecording]
	var images: [NoteImage]
	var location: Location
	var text: String
	var uploaded: Date?

	init(
		audioRecordings: [AudioRecording],
		images: [NoteImage],
		location: Location,
		text: String,
		uploaded: Date? = nil,
		uuid: UUID = UUID()
	) {
		self.id = uuid
		self.audioRecordings = audioRecordings
		self.images = images
		self.location = location
		self.timestamp = Date.now
		self.text = text
		self.uploaded = uploaded
	}

	static func forPreview(
		audioRecordings: [AudioRecording] = [],
		images: [NoteImage] = [],
		location: Location = .visalia,
		text: String = "some text"
	) -> NidusNote {
		return NidusNote(
			audioRecordings: audioRecordings,
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
			uuid: id,
			timestamp: timestamp,
			audio: audioRecordings.map(\.uuid),
			images: images.map(\.uuid),
			location: location,
			text: text
		)
	}
}
