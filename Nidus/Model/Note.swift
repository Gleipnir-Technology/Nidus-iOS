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
	static let nidus = NoteCategory(color: .purple, icon: "mappin", name: "Nidus Native")
	static let serviceRequest = NoteCategory(
		color: .green,
		icon: "clipboard",
		name: "Service Request"
	)
	static let trapData = NoteCategory(color: .blue, icon: "hazardsign", name: "Trap Data")

	static let all = [mosquitoSource, nidus, serviceRequest, trapData]
}

protocol Note: Identifiable<UUID>, Hashable {
	var category: NoteCategory { get }
	var categoryName: String { get }
	var color: Color { get }
	var content: String { get }
	var h3cell: H3Cell { get }
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
	var h3cell: H3Cell { innerNote.h3cell }
	var id: UUID {
		innerNote.id
	}
	var timestamp: Date { innerNote.timestamp }

	func asMosquitoSource() -> MosquitoSource? {
		return innerNote as? MosquitoSource
	}
	func asNidusNote() -> NidusNote? {
		return innerNote as? NidusNote
	}
	func asServiceRequest() -> ServiceRequest? {
		return innerNote as? ServiceRequest
	}
	func asTrapData() -> TrapData? {
		return innerNote as? TrapData
	}
	static func == (lhs: AnyNote, rhs: AnyNote) -> Bool {
		return lhs.category == rhs.category && lhs.content == rhs.content
			&& lhs.id == rhs.id && lhs.timestamp == rhs.timestamp
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(innerNote)
	}
}
