import ClusterMap
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

struct NoteCategory: Hashable, Identifiable {
	var id: String

	var color: Color
	var icon: String
	var name: String

	init(color: Color, icon: String, name: String) {
		self.color = color
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

protocol Note: Identifiable<UUID>, CoordinateIdentifiable, Hashable {
	var category: NoteCategory { get }
	var categoryName: String { get }
	var color: Color { get }
	var content: String { get }
	var coordinate: CLLocationCoordinate2D { get set }
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
	var color: Color { innerNote.color }
	var content: String { innerNote.content }
	var id: UUID {
		innerNote.id
	}
	var coordinate: CLLocationCoordinate2D {
		get {
			innerNote.coordinate
		}
		set {
			innerNote.coordinate = newValue
		}
	}
	var timestamp: Date { innerNote.timestamp }
	static func == (lhs: AnyNote, rhs: AnyNote) -> Bool {
		return lhs.category == rhs.category && lhs.content == rhs.content
			&& lhs.id == rhs.id && lhs.timestamp == rhs.timestamp
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(innerNote)
	}
}
