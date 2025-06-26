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
	var content: String { return "something something" }
	var coordinate: CLLocationCoordinate2D {
		get {
			return location.coordinate
		}
		set {
			location = CLLocation(
				latitude: newValue.latitude,
				longitude: newValue.longitude
			)
		}
	}
	var id: UUID
	var timestamp: Date
	/* end Note protocol */

	var location: CLLocation

	init(location: CLLocation) {
		self.id = UUID()
		self.location = location
		self.timestamp = Date.now
	}

	static func == (lhs: NidusNote, rhs: NidusNote) -> Bool {
		return lhs.location == rhs.location
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(location)
	}
}
