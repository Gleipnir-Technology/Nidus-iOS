//
//  3.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/1/25.
//

import Foundation
import SQLite
import SQLiteMigrationManager

struct Migration3: Migration {
	var version: Int64 = 2025_07_01_1733_0000

	class AudioRecordingTable {
		let table = Table("audio_recording")

		let uploaded = SQLite.Expression<Date?>("uploaded")
	}

	class ImageTable {
		let table = Table("image")

		let uploaded = SQLite.Expression<Date?>("uploaded")
	}

	class NoteTable {
		let table = Table("note")

		let uploaded = SQLite.Expression<Date?>("uploaded")
	}

	func migrateDatabase(_ db: Connection) throws {
		let audio_recording = Migration3.AudioRecordingTable()
		let image = Migration3.ImageTable()
		let note = Migration3.NoteTable()

		try db.run(
			audio_recording.table.addColumn(audio_recording.uploaded)
		)
		try db.run(
			image.table.addColumn(image.uploaded)
		)
		try db.run(
			note.table.addColumn(note.uploaded)
		)
	}
}
