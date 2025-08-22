import Foundation
import H3
import MapKit
import OSLog

class PictureNote: NoteProtocol, Codable {
	enum CodingKeys: CodingKey {
		case id
		case cell
		case created
	}
	let id: UUID
	var cell: H3Cell
	var created: Date

	var location: H3Cell {
		return cell
	}
	var timestamp: Date {
		return created
	}

	init(id: UUID, location: H3Cell?, timestamp: Date) {
		self.id = id
		self.cell = location ?? 0
		self.named = nil
		self.created = timestamp
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(UUID.self, forKey: .id)
		cell = try container.decode(H3Cell.self, forKey: .cell)
		created = try container.decode(Date.self, forKey: .created)
		named = nil
	}

	// Strictly for previews
	let named: String?
	init(named: String, location: H3Cell?) {
		self.id = UUID()
		self.named = named
		self.cell = location ?? 0
		self.created = Date.now
	}

	static func forPreview(location: H3Cell) -> PictureNote {
		return PictureNote(named: "mosquito-wide", location: location)
	}
	// end previews

	var category: NoteType {
		return .picture
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(cell, forKey: .cell)
		try container.encode(created, forKey: .created)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(cell)
		hasher.combine(created)
	}

	var mapAnnotation: NoteMapAnnotation {
		do {
			let coordinate = try cellToLatLng(cell: cell)
			return NoteMapAnnotation(
				coordinate: coordinate,
				icon: "photo",
				text: ""
			)
		}
		catch {
			Logger.foreground.warning("Faled to convert H3Cell to coordinate: \(error)")
			return NoteMapAnnotation(
				coordinate: CLLocationCoordinate2D(latitude: -180, longitude: 180),
				icon: "photo",
				text: ""
			)
		}
	}
	var overview: NoteOverview {
		return NoteOverview(
			color: .cyan,
			icon: iconForNoteType(category),
			icons: [],
			id: id,
			location: cell,
			time: created
		)
	}
	var uiImage: UIImage {
		// For previews!
		if self.named != nil {
			return UIImage(named: self.named!) ?? PLACEHOLDER!
		}

		let url = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		).appendingPathComponent("\(id).photo")
		do {
			let imagedata = try Data(contentsOf: url)
			guard let image = UIImage(data: imagedata) else {
				Logger.foreground.error("Failed to load image from \(url)")
				return PLACEHOLDER!
			}
			return image
		}
		catch {
			Logger.foreground.error("Failed to read image from \(url): \(error)")
			return PLACEHOLDER!
		}
	}

	static func == (lhs: PictureNote, rhs: PictureNote) -> Bool {
		return lhs.id == rhs.id && lhs.cell == rhs.cell && lhs.created == rhs.created
	}
}

let PLACEHOLDER = UIImage(
	systemName: "photo.badge.exclamationmark",
	withConfiguration: UIImage.SymbolConfiguration(pointSize: 72)
)
