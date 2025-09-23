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
		case breadcrumbs
		case tags
		case transcription
		case transcriptionUserEdited
		case version
	}

	let id: UUID
	var breadcrumbs: [AudioNoteBreadcrumb]
	let created: Date
	let duration: TimeInterval
	var tags: [AudioTagMatch]
	var transcription: String?
	var transcriptionUserEdited: Bool
	let version: Int

	var timestamp: Date {
		return created
	}
	var url: URL {
		return AudioNote.url(self.id)
	}

	init(
		id: UUID = UUID(),
		breadcrumbs: [AudioNoteBreadcrumb],
		created: Date = Date(),
		duration: TimeInterval,
		transcription: String? = nil,
		transcriptionUserEdited: Bool = false,
		version: Int
	) {
		self.id = id
		self.breadcrumbs = breadcrumbs
		self.created = created
		self.duration = duration
		self.tags = transcription == nil ? [] : AudioTagIdentifier.parseTags(transcription!)
		self.transcription = transcription
		self.transcriptionUserEdited = transcriptionUserEdited
		self.version = version
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(UUID.self, forKey: .id)!
		created = try container.decode(Date.self, forKey: .created)
		duration = try container.decode(TimeInterval.self, forKey: .duration)
		breadcrumbs =
			try container.decodeIfPresent(
				[AudioNoteBreadcrumb].self,
				forKey: .breadcrumbs
			) ?? []
		transcription = try container.decode(String.self, forKey: .transcription)
		transcriptionUserEdited = try container.decode(
			Bool.self,
			forKey: .transcriptionUserEdited
		)
		version = try container.decode(Int.self, forKey: .version)

		tags = AudioTagIdentifier.parseTags(transcription ?? "")
	}

	var category: NoteType {
		return .audio
	}

	var cell: H3Cell {
		return breadcrumbs.isEmpty
			? RegionControllerPreview.userCell : breadcrumbs[breadcrumbs.count - 1].cell
	}

	var mapAnnotation: NoteMapAnnotation {
		do {
			let coordinate = try cellToLatLng(cell: cell)
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
			color: colorForNoteType(category),
			icon: iconForNoteType(category),
			icons: [],
			id: id,
			location: cell,
			time: created,
			type: category
		)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(created, forKey: .created)
		try container.encode(duration, forKey: .duration)
		try container.encode(breadcrumbs, forKey: .breadcrumbs)
		//try container.encode(tags, forKey: .tags)
		try container.encode(transcription, forKey: .transcription)
		try container.encode(transcriptionUserEdited, forKey: .transcriptionUserEdited)
		try container.encode(version, forKey: .version)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(breadcrumbs)
		hasher.combine(created)
		hasher.combine(tags)
		hasher.combine(transcription)
		hasher.combine(transcriptionUserEdited)
		hasher.combine(version)
	}

	static func == (lhs: AudioNote, rhs: AudioNote) -> Bool {
		return lhs.id == rhs.id && lhs.breadcrumbs == rhs.breadcrumbs
			&& lhs.tags == rhs.tags && lhs.created == rhs.created
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
			breadcrumbs: [
				AudioNoteBreadcrumb(
					cell: 0x8f4_8eba_314c_0ac5,
					created: Date.now.advanced(by: -30)
				)
			],
			duration: 12,
			transcription: "This is something I said",
			version: 1
		)
	}
}
