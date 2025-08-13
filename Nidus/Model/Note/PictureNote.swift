import Foundation
import H3
import MapKit
import OSLog

struct PictureNote: NoteProtocol {
	let id: UUID
	var location: H3Cell
	var timestamp: Date

	init(id: UUID, location: H3Cell?, timestamp: Date) {
		self.id = id
		self.location = location ?? 0
		self.named = nil
		self.timestamp = timestamp
	}

	// Strictly for previews
	let named: String?
	init(named: String, location: H3Cell?) {
		self.id = UUID()
		self.named = named
		self.location = location ?? 0
		self.timestamp = Date.now
	}

	static func forPreview(location: H3Cell) -> PictureNote {
		return PictureNote(named: "mosquito-wide", location: location)
	}
	// end previews

	var category: NoteType {
		return .picture
	}
	var mapAnnotation: NoteMapAnnotation {
		do {
			let coordinate = try cellToLatLng(cell: location)
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
			location: location,
			time: timestamp
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
		).appendingPathComponent("\(id).png")
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
}

let PLACEHOLDER = UIImage(
	systemName: "photo.badge.exclamationmark",
	withConfiguration: UIImage.SymbolConfiguration(pointSize: 72)
)
