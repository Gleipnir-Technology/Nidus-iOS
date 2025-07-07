//
//  NewNote.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/4/25.
//
import MapKit
import SwiftUI

@Observable
class ModelNoteBuffer {
	var audioRecordings: [AudioRecording] = []
	var dueDate: Date = Date()
	var capturedImages: [UIImage] = []
	var location: CLLocation?
	var text: String = ""

	var showLocationToast = false
	var showSavedToast = false
	var showSavedErrorToast = false

	var note: NidusNote? = nil

	func toNote() -> NidusNote {
		guard let result = note else {
			return NidusNote(
				audioRecordings: audioRecordings,
				images: capturedImages.map { NoteImage($0) },
				location: Location(location!),
				text: text
			)
		}
		result.audioRecordings = audioRecordings
		result.images = capturedImages.map { NoteImage($0) }
		result.location = Location(location!)
		result.text = text
		return result
	}

	func Reset(_ note: NidusNote?) {
		guard let note = note else {
			self.audioRecordings = []
			self.capturedImages = []
			self.location = nil
			self.text = ""
			return
		}
		self.note = note
		self.audioRecordings = note.audioRecordings
		let maybeImages = note.images.map { $0.toUIImage() }
		self.capturedImages = maybeImages.compactMap { $0 }
		self.location = CLLocation(
			latitude: note.location.latitude,
			longitude: note.location.longitude
		)
		self.text = note.text
	}
}
