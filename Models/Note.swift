//
//  Task.swift
//  Nidus
//
//  Created by Eli Ribble on 3/10/25.
//
import CoreLocation
import SwiftData
import SwiftUI

@Model
final class NoteLocation {
	var latitude: Double
	var longitude: Double

	init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
	init(location: CLLocation) {
		self.latitude = location.coordinate.latitude
		self.longitude = location.coordinate.longitude
	}

	func asCLLocationCoordinate2D() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(
			latitude: self.latitude,
			longitude: self.longitude
		)
	}
}

struct ColorComponents: Codable {
	let red: Float
	let green: Float
	let blue: Float

	var color: Color {
		Color(red: Double(red), green: Double(green), blue: Double(blue))
	}

	static func fromColor(_ color: Color) -> ColorComponents {
		let resolved = color.resolve(in: EnvironmentValues())
		return ColorComponents(
			red: resolved.red,
			green: resolved.green,
			blue: resolved.blue
		)
	}
}

@Model
final class NoteCategory {
	var color: ColorComponents
	var icon: String
	@Attribute(.unique) var name: String
	@Relationship(deleteRule: .cascade, inverse: \Note.category)
	var notes = [Note]()

	init(color: Color, icon: String, name: String) {
		self.color = ColorComponents.fromColor(color)
		self.icon = icon
		self.name = name
	}
}

@Model
final class Note: Identifiable {
	var category: NoteCategory
	var content: String
	var id: UUID = UUID()
	var location: NoteLocation?
	var timestamp: Date = Date()

	init(category: NoteCategory, content: String, location: NoteLocation?) {
		self.category = category
		self.content = content
		self.location = location
	}

	func coordinate() -> CLLocationCoordinate2D? {
		guard let location = location else { return nil }
		return location.asCLLocationCoordinate2D()
	}
}
