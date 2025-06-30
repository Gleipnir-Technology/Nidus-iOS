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

	init(
		audioRecordings: [AudioRecording],
		images: [NoteImage],
		location: Location,
		text: String,
		uuid: UUID = UUID()
	) {

		self.id = uuid
		self.audioRecordings = audioRecordings
		self.images = images
		self.location = location
		self.timestamp = Date.now
		self.text = text
	}

	static func forPreview(latitude: Double, longitude: Double) -> NidusNote {
		return NidusNote(
			audioRecordings: [],
			images: [],
			location: Location(latitude: latitude, longitude: longitude),
			text: ""
		)
	}
	static func == (lhs: NidusNote, rhs: NidusNote) -> Bool {
		return lhs.location == rhs.location
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(location)
	}
}
