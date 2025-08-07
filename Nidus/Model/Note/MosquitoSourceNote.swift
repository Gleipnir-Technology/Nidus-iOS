import Foundation
import H3
import MapKit
import OSLog

struct MosquitoSourceNote: NoteProtocol {
	static let ICON: String = "ant.fill"

	let id: UUID
	var location: H3Cell
	var timestamp: Date

	init(id: UUID = UUID(), location: H3Cell, timestamp: Date = Date()) {
		self.id = id
		self.location = location
		self.timestamp = timestamp
	}

	var category: NoteType {
		return .mosquitoSource
	}

	var mapAnnotation: NoteMapAnnotation {
		do {
			let coordinate = try cellToLatLng(cell: location)
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
			color: .red,
			icon: MosquitoSourceNote.ICON,
			icons: [],
			location: location,
			time: Date.now
		)
	}
}
