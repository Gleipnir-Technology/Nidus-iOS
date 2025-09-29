import Foundation
import H3
import MapKit
import OSLog

struct MosquitoSourceNote: NoteProtocol {
	static let ICON: String = "ant.fill"

	var access: String
	var active: Bool?
	var comments: String
	var created: Date
	var description: String
	var habitat: String
	// habitat is one of 40 discrete string values like "catch_basin" or "slough" or "watering_bowl"
	let id: UUID
	var cell: H3Cell
	var inspections: [Inspection]
	var lastInspectionDate: Date
	var name: String
	var nextActionDateScheduled: Date
	var treatments: [Treatment]
	var useType: String
	// useType is one of many  string values like "commercial" or "mixed_use"
	var waterOrigin: String
	var zone: String

	init(
		access: String,
		active: Bool?,
		comments: String,
		created: Date,
		description: String,
		habitat: String,
		id: UUID,
		inspections: [Inspection],
		lastInspectionDate: Date,
		location: H3Cell,
		name: String,
		nextActionDateScheduled: Date,
		treatments: [Treatment],
		useType: String,
		waterOrigin: String,
		zone: String
	) {
		self.access = access
		self.active = active
		self.comments = comments
		self.created = created
		self.description = description
		self.habitat = habitat
		self.id = id
		self.inspections = inspections
		self.lastInspectionDate = lastInspectionDate
		self.cell = location
		self.name = name
		self.nextActionDateScheduled = nextActionDateScheduled
		self.treatments = treatments
		self.useType = useType
		self.waterOrigin = waterOrigin
		self.zone = zone
	}

	var category: NoteType {
		return .mosquitoSource
	}

	var coordinate: CLLocationCoordinate2D {
		do {
			return try cellToLatLng(cell: cell)
		}
		catch {
			return CLLocationCoordinate2D(latitude: -180, longitude: 180)
		}
	}
	var icons: Set<NoteOverviewIcon> {
		var results: Set<NoteOverviewIcon> = []

		if active != nil && active! {
			results.insert(.SourceActive)
		}
		if access != "" {
			results.insert(.ContactInformationAvailable)
		}
		if comments != "" {
			results.insert(.HasComments)
		}
		// TODO eliribble
		// Parse comments and description for useful information
		if habitat != "" {
			results.insert(.HasHabitat)
		}
		if inspections.count > 0 {
			results.insert(.HasInspections)
		}
		if nextActionDateScheduled > Date.now {
			results.insert(.HasNextActionScheduled)
		}
		if treatments.count > 0 {
			results.insert(.HasTreatments)
		}
		if useType != "" {
			results.insert(.HasUseType)
		}
		if waterOrigin != "" {
			results.insert(.HasWaterOrigin)
		}
		return results
	}

	var mapAnnotation: NoteMapAnnotation {
		do {
			let coordinate = try cellToLatLng(cell: cell)
			return NoteMapAnnotation(
				coordinate: coordinate,
				icon: MosquitoSourceNote.ICON,
				text: ""
			)
		}
		catch {
			Logger.foreground.warning("Faled to convert H3Cell to coordinate: \(error)")
			return NoteMapAnnotation(
				coordinate: CLLocationCoordinate2D(latitude: -180, longitude: 180),
				icon: MosquitoSourceNote.ICON,
				text: ""
			)
		}
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
	var timestamp: Date {
		created
	}
}
