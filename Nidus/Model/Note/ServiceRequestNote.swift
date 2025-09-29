import Foundation
import H3
import MapKit

struct ServiceRequestNote: NoteProtocol {
	static let ICON: String = "person.wave.2.fill"

	var address: String
	var assignedTechnician: String
	var cell: H3Cell
	var city: String
	var created: Date
	var hasDog: Bool?
	var hasSpanishSpeaker: Bool?
	var id: UUID
	var location: Location
	var priority: String
	var source: String
	var status: String
	var target: String
	var zip: String

	init(
		address: String,
		assignedTechnician: String,
		city: String,
		created: Date,
		hasDog: Bool?,
		hasSpanishSpeaker: Bool?,
		id: UUID,
		location: Location,
		priority: String,
		source: String,
		status: String,
		target: String,
		zip: String
	) {
		self.address = address
		self.assignedTechnician = assignedTechnician
		do {
			self.cell = try latLngToCell(latLng: location.coordinate(), resolution: 15)
		}
		catch {
			self.cell = .init(0)
		}
		self.city = city
		self.created = created
		self.hasDog = hasDog
		self.hasSpanishSpeaker = hasSpanishSpeaker
		self.id = id
		self.location = location
		self.priority = priority
		self.source = source
		self.status = status
		self.target = target
		self.zip = zip
	}

	var category: NoteType {
		return .serviceRequest
	}

	var coordinate: CLLocationCoordinate2D {
		return location.coordinate()
	}

	var icons: Set<NoteOverviewIcon> {
		return []
	}

	var mapAnnotation: NoteMapAnnotation {
		return NoteMapAnnotation(
			coordinate: location.coordinate(),
			icon: ServiceRequestNote.ICON,
			text: ""
		)
	}

	var overview: NoteOverview {
		return NoteOverview(
			color: colorForNoteType(category),
			icon: iconForNoteType(category),
			icons: icons,
			id: id,
			location: cell,
			time: created,
			type: category
		)
	}
}
