import OSLog
import Sentry
import SwiftUI

struct Boundary {
	let minLat: Double
	let minLng: Double
	let maxLat: Double
	let maxLng: Double
}

let H3_MAX_RESOLUTION_FOR_SUMMARY: UInt = 14

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
	func updateSummaryTables(_ onProgress: @escaping (Double) -> Void) async throws {
		let totalNotes = try service.notesCount()
		let totalWork = totalNotes * H3_MAX_RESOLUTION_FOR_SUMMARY
		var currentWorkUnits: Double = 0
		let partialProgress: (UInt) -> Void = { workUnits in
			currentWorkUnits += Double(workUnits)
			Logger.foreground.info(
				"Updated with \(workUnits) new work units, currently at \(currentWorkUnits) / \(totalWork) or \(currentWorkUnits / Double(totalWork) * 100)%)"
			)
			onProgress(currentWorkUnits / Double(totalWork))
		}
		TrackTime("database optimize") {
			updateSummaryAudioNote(partialProgress)
			updateSummaryMosquitoSource(partialProgress)
			updateSummaryPictureNote(partialProgress)
		}
	}

	private func boundaryForNoteType(_ noteType: NoteType) throws -> Boundary {
		return try service.boundaryForNoteType(noteType)
	}

	private func saveNoteSummary(
		_ notes: [any NoteProtocol],
		_ noteType: NoteType,
		onProgress: (UInt) -> Void
	) {
		var workUnits: UInt = 0
		//Logger.foreground.info("Saving note summaries for \(noteType.toString()) with \(notes.count) notes. Expecting \(UInt(notes.count) * H3_MAX_RESOLUTION_FOR_SUMMARY) work units")
		for resolution in 0..<(H3_MAX_RESOLUTION_FOR_SUMMARY - 1) {
			TrackTime("saveNoteSummary \(noteType.toString()) resolution \(resolution)")
			{
				var cellToNoteCount: [UInt64: Int] = [:]
				for note in notes {
					workUnits += 1
					if workUnits % 100 == 0 {
						onProgress(workUnits)
						workUnits = 0
					}
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

	private func updateSummaryAudioNote(_ onProgress: (UInt) -> Void) {
		do {
			let allAudioNotes = try service.notesAudio()
			saveNoteSummary(allAudioNotes, .audio, onProgress: onProgress)
		}
		catch {
			CaptureError(error, "optimizeAudioNote")
			return
		}
	}

	private func updateSummaryPictureNote(_ onProgress: (UInt) -> Void) {
		do {
			let allNotes = try service.notesPicture()
			saveNoteSummary(allNotes, .picture, onProgress: onProgress)
		}
		catch {
			CaptureError(error, "optimizeAudioNote")
			return
		}
	}

	private func updateSummaryMosquitoSource(_ onProgress: (UInt) -> Void) {
		do {
			let allSourceNotes = try service.notesMosquitoSource()
			saveNoteSummary(allSourceNotes, .mosquitoSource, onProgress: onProgress)
		}
		catch {
			CaptureError(error, "optimizeMosquitoSource")
		}
	}

}
