import Foundation
import SQLite
import SQLiteMigrationManager

/// Make the audio recording table have a version and a UUID so that we can track changes
struct Migration10: Migration {
	var version: Int64 = 2025_08_27_1355_0000

	class AudioRecordingTable {
		let table = Table("audio_recording")

		let created = SQLite.Expression<Date>("created")
		let deleted = SQLite.Expression<Date?>("deleted")
		let duration = SQLite.Expression<TimeInterval>("duration")
		let transcription = SQLite.Expression<String?>("transcription")
		let transcriptionUserEdited = SQLite.Expression<Bool>("transcription_user_edited")
		let uploaded = SQLite.Expression<Date?>("uploaded")
		let uuid = SQLite.Expression<UUID>("uuid")
		let version = SQLite.Expression<Int>("version")
	}

	func migrateDatabase(_ db: Connection) throws {
		let audio_recording = Migration10.AudioRecordingTable()

		// Reference: https://www.techonthenet.com/sqlite/foreign_keys/drop.php
		try db.execute("PRAGMA foreign_keys=off;")
		try db.execute("DROP TABLE IF EXISTS _audio_recording_old")
		try db.execute("ALTER TABLE audio_recording RENAME TO _audio_recording_old;")
		try db.run(
			audio_recording.table.create(ifNotExists: false) { t in
				t.column(audio_recording.created)
				t.column(audio_recording.deleted)
				t.column(audio_recording.duration)
				t.column(audio_recording.transcription)
				t.column(audio_recording.transcriptionUserEdited)
				t.column(audio_recording.uploaded)
				t.column(audio_recording.uuid)
				t.column(audio_recording.version)
				t.primaryKey(audio_recording.uuid, audio_recording.version)
			}
		)
		try db.execute(
			"INSERT INTO audio_recording SELECT created, deleted, duration, transcription, FALSE, uploaded, uuid, 1 FROM _audio_recording_old;"
		)
		try db.execute("PRAGMA foreign_keys=on;")
	}
}
