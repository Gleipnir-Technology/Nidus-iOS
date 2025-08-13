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
		self.timestamp = timestamp
	}

	static func forPreview(location: H3Cell) -> PictureNote {
		return PictureNote(id: UUID(), location: location, timestamp: Date.now)
	}

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
				return UIImage(named: "picture")!
			}
			return image
		}
		catch {
			Logger.foreground.error("Failed to read image from \(url): \(error)")
			return UIImage(named: "picture")!
		}
	}
}
