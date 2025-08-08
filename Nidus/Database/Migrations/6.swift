import Foundation
import SQLite
import SQLiteMigrationManager

struct Migration6: Migration {
	var version: Int64 = 2025_08_07_1530_0000

	class AudioRecordingTable {
		let table = Table("audio_recording")

		let created = SQLite.Expression<Date>("created")
		let deleted = SQLite.Expression<Date?>("deleted")
		let duration = SQLite.Expression<TimeInterval>("duration")
		// This is what we are removing
		let noteUUID = SQLite.Expression<UUID>("note_uuid")
		let transcription = SQLite.Expression<String?>("transcription")
		let uploaded = SQLite.Expression<Date?>("uploaded")
		let uuid = SQLite.Expression<UUID>("uuid")
	}

	func migrateDatabase(_ db: Connection) throws {
		let audio_recording = Migration6.AudioRecordingTable()

		// Reference: https://www.techonthenet.com/sqlite/foreign_keys/drop.php
		try db.execute("PRAGMA foreign_keys=off;")
		try db.execute("ALTER TABLE audio_recording RENAME TO _audio_recording_old;")
		try db.run(
			audio_recording.table.create(ifNotExists: false) { t in
				t.column(audio_recording.created)
				t.column(audio_recording.deleted)
				t.column(audio_recording.duration)
				t.column(audio_recording.transcription)
				t.column(audio_recording.uploaded)
				t.column(audio_recording.uuid, primaryKey: true)
			}
		)
		try db.execute(
			"INSERT INTO audio_recording SELECT created, deleted, duration, transcription, uploaded, uuid FROM _audio_recording_old;"
		)
		try db.execute("PRAGMA foreign_keys=on;")
	}
}
