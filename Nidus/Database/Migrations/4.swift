//
//  4.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/4/25.
//

import Foundation
import SQLite
import SQLiteMigrationManager

struct Migration4: Migration {
	var version: Int64 = 2025_07_04_1943_0000

	class AudioRecordingTable {
		let table = Table("audio_recording")

		let deleted = SQLite.Expression<Date?>("deleted")
	}

	class ImageTable {
		let table = Table("image")

		let deleted = SQLite.Expression<Date?>("deleted")
	}

	class NoteTable {
		let table = Table("note")

		let deleted = SQLite.Expression<Date?>("deleted")
	}

	func migrateDatabase(_ db: Connection) throws {
		let audio_recording = Migration4.AudioRecordingTable()
		let image = Migration4.ImageTable()
		let note = Migration4.NoteTable()

		try db.run(
			audio_recording.table.addColumn(audio_recording.deleted)
		)
		try db.run(
			image.table.addColumn(image.deleted)
		)
		try db.run(
			note.table.addColumn(note.deleted)
		)
	}
}
