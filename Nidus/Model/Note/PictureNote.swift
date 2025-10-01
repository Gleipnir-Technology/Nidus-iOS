import Foundation
import H3
import MapKit
import OSLog
import SwiftUI

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

	init(id: UUID, cell: H3Cell?, created: Date) {
		self.id = id
		self.cell = cell ?? 0
		self.created = created
		self.named = nil
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

	static func url(_ uuid: UUID, ext: String = "photo") -> URL {
		let supportURL = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		)
		return supportURL.appendingPathComponent("\(uuid).\(ext)")
	}

	static func urlForPreview(_ uuid: UUID) -> URL {
		let supportURL = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		)
		return supportURL.appendingPathComponent("\(uuid)-preview.png")
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
			color: colorForNoteType(category),
			icon: thumbnail,
			icons: [],
			id: id,
			location: cell,
			time: created,
			type: category
		)
	}
	var thumbnail: Image {
		let url = PictureNote.urlForPreview(id)
		do {
			let data = try Data(contentsOf: url)
			guard let image = UIImage(data: data) else {
				return Image(uiImage: PLACEHOLDER!)
			}
			return Image(uiImage: image).resizable()
		}
		catch {
			Logger.foreground.error(
				"Failed to read thumbnail image from \(url): \(error)"
			)
			guard let generated = generateThumbnailOrPlaceholder() else {
				return Image(uiImage: PLACEHOLDER!).resizable()
			}
			return Image(uiImage: generated).resizable()
		}
	}

	func generateThumbnailOrPlaceholder() -> UIImage? {
		do {
			let image = try loadImage()
			let size = CGSize(width: 128, height: 128)
			UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
			image.draw(in: CGRect(origin: CGPoint.zero, size: size))
			let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return thumbnailImage
		}
		catch {
			Logger.foreground.error(
				"Failed to load image: \(error). Can't generate thumbnail"
			)
			return nil
		}
	}

	func loadImage() throws -> UIImage {
		let url = PictureNote.url(id)
		let imagedata = try Data(contentsOf: url)
		guard let image = UIImage(data: imagedata) else {
			Logger.foreground.error(
				"Failed to load image from \(url), trying alternate"
			)
			// If we get here, try a different extension in case its an older image
			let urlAlt = PictureNote.url(id, ext: "png")
			let imageDataAlt = try Data(contentsOf: urlAlt)
			guard let imageAlt = UIImage(data: imageDataAlt) else {
				Logger.foreground.error(
					"Failed to load image from \(urlAlt), giving up"
				)
				return PLACEHOLDER!
			}
			return imageAlt
		}
		return image
	}

	var uiImage: UIImage {
		// For previews!
		if self.named != nil {
			return UIImage(named: self.named!) ?? PLACEHOLDER!
		}
		do {
			return try loadImage()
		}
		catch {
			Logger.foreground.error("Failed to load image, using placeholder")
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
