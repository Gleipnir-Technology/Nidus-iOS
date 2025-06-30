//
//  2.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/29/25.
//

import Foundation
import SQLite
import SQLiteMigrationManager

struct Migration2: Migration {
	var version: Int64 = 2025_06_29_1222_0000

	class AudioRecordingTable {
		let table = Table("audio_recording")

		let created = SQLite.Expression<Date>("created")
		let duration = SQLite.Expression<TimeInterval>("duration")
		let transcription = SQLite.Expression<String?>("transcription")
		let noteUUID = SQLite.Expression<UUID>("note_uuid")
		let uuid = SQLite.Expression<UUID>("uuid")
	}

	class ImageTable {
		let table = Table("image")

		let created = SQLite.Expression<Date>("created")
		let noteUUID = SQLite.Expression<UUID>("note_uuid")
		let uuid = SQLite.Expression<UUID>("uuid")
	}

	class NoteTable {
		let table = Table("note")

		let latitude = SQLite.Expression<Double>("latitude")
		let longitude = SQLite.Expression<Double>("longitude")
		let text = SQLite.Expression<String>("text")
		let timestamp = SQLite.Expression<Date>("timestamp")
		let uuid = SQLite.Expression<UUID>("uuid")
	}

	func migrateDatabase(_ db: Connection) throws {
		let audio_recording = Migration2.AudioRecordingTable()
		let image = Migration2.ImageTable()
		let note = Migration2.NoteTable()

		try db.run(
			note.table.create(ifNotExists: true) { t in
				t.column(note.latitude)
				t.column(note.longitude)
				t.column(note.text)
				t.column(note.timestamp)
				t.column(note.uuid, primaryKey: true)
			}
		)
		try db.run(
			audio_recording.table.create(ifNotExists: true) { t in
				t.column(audio_recording.created)
				t.column(audio_recording.duration)
				t.column(audio_recording.noteUUID)
				t.column(audio_recording.transcription)
				t.column(audio_recording.uuid, primaryKey: true)
				t.foreignKey(
					audio_recording.noteUUID,
					references: note.table,
					note.uuid,
					delete: .cascade
				)
			}
		)
		try db.run(
			image.table.create(ifNotExists: true) { t in
				t.column(image.created)
				t.column(image.noteUUID)
				t.column(image.uuid, primaryKey: true)
				t.foreignKey(
					image.noteUUID,
					references: note.table,
					note.uuid,
					delete: .cascade
				)
			}
		)
	}
}
