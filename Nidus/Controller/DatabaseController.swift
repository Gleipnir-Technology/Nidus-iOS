import OSLog
import Sentry
import SwiftUI

struct Boundary {
	let minLat: Double
	let minLng: Double
	let maxLat: Double
	let maxLng: Double
}

@Observable
class DatabaseController {
	// TODO: make this private eventually
	var service: DatabaseService

	init() {
		self.service = DatabaseService()
	}

	func connect() throws {
		try service.connect()
		try service.migrateIfNeeded()
	}

	/// Calculate  contents of optimization tables
	func optimize() async {
		TrackTime("database optimize") {
			for noteType in NoteType.allCases {
				switch noteType {
				case .audio:
					optimizeAudioNote()
				case .mosquitoSource:
					optimizeMosquitoSource()
				case .picture:
					optimizeImageNote()
				}
			}
		}
	}
	private func optimizeAudioNote() {
		do {
			let allAudioNotes = try service.notesAudio()
			saveNoteSummary(allAudioNotes, .audio)
		}
		catch {
			CaptureError(error, "optimizeAudioNote")
			return
		}
	}

	private func optimizeImageNote() {
		do {
			let allNotes = try service.notesPicture()
			saveNoteSummary(allNotes, .picture)
		}
		catch {
			CaptureError(error, "optimizeAudioNote")
			return
		}
	}

	private func optimizeMosquitoSource() {
		do {
			let allSourceNotes = try service.notesMosquitoSource()
			saveNoteSummary(allSourceNotes, .mosquitoSource)
		}
		catch {
			CaptureError(error, "optimizeMosquitoSource")
		}
	}

	private func boundaryForNoteType(_ noteType: NoteType) throws -> Boundary {
		return try service.boundaryForNoteType(noteType)
	}

	private func saveNoteSummary(_ notes: [any NoteProtocol], _ noteType: NoteType) {
		for resolution in 0..<15 {
			TrackTime("saveNoteSummary \(noteType.toString()) resolution \(resolution)")
			{
				var cellToNoteCount: [UInt64: Int] = [:]
				for note in notes {
					do {
						let cell = try scaleCell(
							note.cell,
							to: resolution
						)
						cellToNoteCount[cell, default: 0] += 1
					}
					catch {
						Logger.background.error(
							"Failed to scale cell \(String(note.cell, radix: 16)) to resolution \(resolution): \(error)"
						)
						continue
					}
				}
				for (cell, count) in cellToNoteCount {
					do {
						try service.noteSummaryByHexUpsert(
							cell: cell,
							cellResolution: resolution,
							count: count,
							noteType: noteType
						)
					}
					catch {
						CaptureError(error, "save noteSummaryByHexUpsert")
					}
				}
			}
		}
	}
}
