import Foundation
import H3
import MapKit
import OSLog
import SwiftUI

class AudioNote: NoteProtocol, Codable {
	enum CodingKeys: CodingKey {
		case id
		case created
		case duration
		case locations
		case tags
		case transcription
	}

	let id: UUID
	let created: Date
	let duration: TimeInterval
	var locations: [H3Cell]
	var tags: [AudioTagMatch]
	var transcription: String?

	var timestamp: Date {
		return created
	}
	var url: URL {
		return AudioNote.url(self.id)
	}

	init(
		id: UUID = UUID(),
		created: Date = Date(),
		duration: TimeInterval,
		locations: [H3Cell],
		transcription: String? = nil
	) {
		self.id = id
		self.created = created
		self.duration = duration
		self.locations = locations
		self.tags = transcription == nil ? [] : AudioTagIdentifier.parseTags(transcription!)
		self.transcription = transcription
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(UUID.self, forKey: .id)!
		created = try container.decode(Date.self, forKey: .created)
		duration = try container.decode(TimeInterval.self, forKey: .duration)
		locations = try container.decodeIfPresent([H3Cell].self, forKey: .locations) ?? []
		//tags = try container.decodeIfPresent(String.self, forKey: .tags)
		tags = []
		transcription = try container.decode(String.self, forKey: .transcription)
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

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(created, forKey: .created)
		try container.encode(duration, forKey: .duration)
		try container.encode(locations, forKey: .locations)
		//try container.encode(tags, forKey: .tags)
		try container.encode(transcription, forKey: .transcription)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(locations)
		hasher.combine(timestamp)
		hasher.combine(tags)
		hasher.combine(transcription)
	}

	static func == (lhs: AudioNote, rhs: AudioNote) -> Bool {
		return lhs.id == rhs.id && lhs.locations == rhs.locations
			&& lhs.tags == rhs.tags && lhs.timestamp == rhs.timestamp
			&& lhs.transcription == rhs.transcription
	}

	static func url(_ uuid: UUID) -> URL {
		let supportURL = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		)
		return supportURL.appendingPathComponent("\(uuid).m4a")
	}

	struct Preview {
		static var one = AudioNote(
			duration: 12,
			locations: [0x8f4_8eba_314c_0ac5],
			transcription: "This is something I said"
		)
	}
}
