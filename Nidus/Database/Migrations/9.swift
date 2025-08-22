import Foundation
import SQLite
import SQLiteMigrationManager

/// Create a table for holding information about location breadcrumbs for audio recordings
struct Migration9: Migration {
	var version: Int64 = 2025_08_21_2000_0000

	class AudioRecordingLocationTable {
		let table = Table("audio_recording_location")

		let audioRecordingUUID = SQLite.Expression<UUID>("audio_recording_uuid")
		let cell = SQLite.Expression<UInt64>("cell")
		let created = SQLite.Expression<Date?>("created")
		let index = SQLite.Expression<Int>("index")
	}

	func migrateDatabase(_ db: Connection) throws {
		let audio_recording_location = Migration9.AudioRecordingLocationTable()

		try db.run(
			audio_recording_location.table.addColumn(audio_recording_location.created)
		)
		let query = audio_recording_location.table.update(
			audio_recording_location.created
				<- SQLite.Expression<Date?>(value: Date.now)
		)
		try db.run(query)
	}
}
