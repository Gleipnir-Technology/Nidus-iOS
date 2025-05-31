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
			return NoteCategory.mosquitoSource
		}
		else {
			let result = NoteCategory.byName(name!)
			if result == nil {
				return NoteCategory.mosquitoSource
			}
			return result!
		}
	}

	static let mosquitoSource = NoteCategory(
		color: .red,
		icon: "ant.circle",
		name: "Mosquito Source"
	)
	static let serviceRequest = NoteCategory(
		color: .green,
		icon: "clipboard",
		name: "Service Request"
	)
	static let trapData = NoteCategory(color: .blue, icon: "hazardsign", name: "Trap Data")

	static let all = [mosquitoSource, serviceRequest, trapData]
}

protocol Note: Identifiable<UUID> {
	var category: NoteCategory { get }
	var categoryName: String { get }
	var content: String { get }
	var coordinate: CLLocationCoordinate2D { get }
	var id: UUID { get }
	var timestamp: Date { get }
}
struct AnyNote: Note {
	var innerNote: any Note

	init(_ note: any Note) {
		innerNote = note
	}
	var category: NoteCategory { innerNote.category }
	var categoryName: String { innerNote.categoryName }
	var content: String { innerNote.content }
	var id: UUID {
		innerNote.id
	}
	var coordinate: CLLocationCoordinate2D { innerNote.coordinate }
	var timestamp: Date { innerNote.timestamp }
}
