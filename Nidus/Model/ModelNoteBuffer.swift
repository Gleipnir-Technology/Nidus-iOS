import H3
import MapKit
import SwiftUI

@Observable
class ModelNoteBuffer {
	var dueDate: Date = Date()
	var capturedImages: [UIImage] = []
	var h3cell: H3Cell = 0
	var location: CLLocation?
	var text: String = ""

	var showLocationToast = false
	var showSavedToast = false
	var showSavedErrorToast = false

	var note: NidusNote? = nil

	func cellOrZero(_ location: CLLocation?) -> H3Cell {
		guard let location = location else {
			return H3Cell()
		}
		do {
			return try latLngToCell(latLng: location.coordinate, resolution: 15)
		}
		catch {
			return H3Cell()
		}
	}
	func toNote() -> NidusNote {
		guard let result = note else {
			return NidusNote(
				h3cell: h3cell,
				images: capturedImages.map { NoteImage($0) },
				text: text
			)
		}
		result.images = capturedImages.map { NoteImage($0) }
		result.text = text

		guard let location = location else {
			result.h3cell = h3cell
			return result
		}
		// Capture any changes to the location
		do {
			let new_cell = try latLngToCell(latLng: location.coordinate, resolution: 15)
			result.h3cell = new_cell
			return result
		}
		catch {
			result.h3cell = h3cell
			return result
		}
	}

	func Reset(_ note: NidusNote?) {
		guard let note = note else {
			self.capturedImages = []
			self.h3cell = 0
			self.location = nil
			self.text = ""
			return
		}
		self.note = note
		let maybeImages = note.images.map { $0.toUIImage() }
		self.capturedImages = maybeImages.compactMap { $0 }
		self.h3cell = note.h3cell
		let l = cellToLatLngOrBust(note.h3cell)
		self.location = CLLocation(latitude: l.latitude, longitude: l.longitude)
		self.text = note.text
	}
}
