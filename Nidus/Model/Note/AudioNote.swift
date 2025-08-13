import Foundation
import H3
import MapKit
import OSLog
import SwiftUI

struct AudioNote: NoteProtocol {
	let id: UUID
	var locations: [H3Cell]
	var tags: [AudioTagMatch]
	var timestamp: Date
	var transcription: String?

	init(
		id: UUID = UUID(),
		locations: [H3Cell],
		timestamp: Date = Date(),
		transcription: String? = nil
	) {
		self.id = id
		self.locations = locations
		self.tags = transcription == nil ? [] : AudioTagIdentifier.parseTags(transcription!)
		self.timestamp = timestamp
		self.transcription = transcription
	}

	var category: NoteType {
		return .audio
	}

	var location: H3Cell {
		return locations.isEmpty
			? RegionControllerPreview.userCell : locations[locations.count - 1]
	}

	var mapAnnotation: NoteMapAnnotation {
		do {
			let coordinate = try cellToLatLng(cell: location)
			return NoteMapAnnotation(
				coordinate: coordinate,
				icon: "waveform",
				text: ""
			)
		}
		catch {
			Logger.foreground.warning("Faled to convert H3Cell to coordinate: \(error)")
			return NoteMapAnnotation(
				coordinate: CLLocationCoordinate2D(latitude: -180, longitude: 180),
				icon: "waveform",
				text: ""
			)
		}
	}
	var overview: NoteOverview {
		return NoteOverview(
			color: .red,
			icon: iconForNoteType(category),
			icons: [],
			id: id,
			location: location,
			time: timestamp
		)
	}

	struct Preview {
		static var one = AudioNote(
			locations: [0x8f4_8eba_314c_0ac5],
			transcription: "This is something I said"
		)
	}
}
