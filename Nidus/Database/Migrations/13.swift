import Foundation
import SQLite
import SQLiteMigrationManager

/// Add a field for whether or not the location value was manually selected
struct Migration13: Migration {
	var version: Int64 = 2025_10_22_1449_0000

	class AudioRecordingLocationTable {
		let table = Table("audio_recording_location")

		let audioRecordingUUID = SQLite.Expression<UUID>("audio_recording_uuid")
		let cell = SQLite.Expression<UInt64>("cell")
		let created = SQLite.Expression<Date>("created")
		let index = SQLite.Expression<Int>("index")
		//New field:
		let manuallySelected = SQLite.Expression<Bool>("manually_selected")
	}

	func migrateDatabase(_ db: Connection) throws {
		let audio_recording_location = Migration13.AudioRecordingLocationTable()

		// Reference: https://www.techonthenet.com/sqlite/foreign_keys/drop.php
		try db.execute("PRAGMA foreign_keys=off;")
		try db.execute("DROP TABLE IF EXISTS _audio_recording_location_old")
		try db.execute(
			"ALTER TABLE audio_recording_location RENAME TO _audio_recording_location_old;"
		)
		try db.run(
			audio_recording_location.table.create(ifNotExists: false) { t in
				t.column(audio_recording_location.audioRecordingUUID)
				t.column(audio_recording_location.cell)
				t.column(audio_recording_location.created)
				t.column(audio_recording_location.index)
				t.column(audio_recording_location.manuallySelected)
			}
		)
		try db.execute(
			"INSERT INTO audio_recording_location SELECT audio_recording_uuid, cell, created, \"index\", FALSE FROM _audio_recording_location_old;"
		)
		try db.execute("PRAGMA foreign_keys=on;")
	}
}
