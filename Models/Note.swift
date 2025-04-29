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

	init() {
		self.latitude = 33.2667195
		self.longitude = -111.8209039
	}
	init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
	init(location: CLLocationCoordinate2D) {
		self.latitude = location.latitude
		self.longitude = location.longitude
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

struct ColorComponents: Codable, Hashable {
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

struct NoteCategory: Codable, Hashable, Identifiable {
	var id: String

	var color: ColorComponents
	var icon: String
	var name: String

	init(color: Color, icon: String, name: String) {
		self.color = ColorComponents.fromColor(color)
		self.icon = icon
		self.name = name
		self.id = name
	}

	static func byName(_ name: String) -> NoteCategory? {
		for category in all {
			if category.name == name {
				return category
			}
		}
		return nil
	}
	static func byNameOrDefault(_ name: String?) -> NoteCategory {
		if name == nil {
			return NoteCategory.info
		}
		else {
			let result = NoteCategory.byName(name!)
			if result == nil {
				return NoteCategory.info
			}
			return result!
		}
	}

	static let entry = NoteCategory(color: .green, icon: "lock.circle", name: "entry")
	static let info = NoteCategory(color: .blue, icon: "info.circle", name: "info")
	static let todo = NoteCategory(color: .red, icon: "checkmark.circle", name: "todo")

	static let all = [entry, info, todo]
}

@Model
final class Note: Identifiable {
	var categoryName: String
	var content: String
	var id: UUID = UUID()
	var location: NoteLocation
	var timestamp: Date = Date()

	init(category: NoteCategory, content: String, location: NoteLocation) {
		self.categoryName = category.name
		self.content = content
		self.location = location
	}

	var category: NoteCategory {
		return NoteCategory.byNameOrDefault(categoryName)
	}
	func coordinate() -> CLLocationCoordinate2D? {
		return location.asCLLocationCoordinate2D()
	}
}
