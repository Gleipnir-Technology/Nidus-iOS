//
//  Task.swift
//  Nidus
//
//  Created by Eli Ribble on 3/10/25.
//
import CoreLocation
import SwiftData

@Model
final class NoteLocation {
	var latitude: Double
	var longitude: Double

	init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
	init(location: CLLocationCoordinate2D) {
		self.latitude = location.latitude
		self.longitude = location.longitude
	}

	func asCLLocationCoordinate2D() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(
			latitude: self.latitude,
			longitude: self.longitude
		)
	}
}

@Model
final class NoteCategory {
	var icon: String
	@Attribute(.unique) var name: String
	@Relationship(deleteRule: .cascade, inverse: \Note.category)
	var notes = [Note]()

	init(icon: String, name: String) {
		self.icon = icon
		self.name = name
	}
}

@Model
final class Note {
	var category: NoteCategory
	var content: String
	var location: NoteLocation?
	var timestamp: Date = Date()

	init(category: NoteCategory, content: String, location: NoteLocation?) {
		self.category = category
		self.content = content
		self.location = location
	}

}
