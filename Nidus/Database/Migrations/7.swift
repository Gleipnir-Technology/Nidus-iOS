import Foundation
import SQLite
import SQLiteMigrationManager

struct Migration7: Migration {
	var version: Int64 = 2025_08_07_1721_0000

	class AudioRecordingLocationTable {
		let table = Table("audio_recording_location")

		let audioRecordingUUID = SQLite.Expression<UUID>("audio_recording_uuid")
		let cell = SQLite.Expression<UInt64>("cell")
		let index = SQLite.Expression<Int>("index")
	}

	func migrateDatabase(_ db: Connection) throws {
		let audio_recording_location = Migration7.AudioRecordingLocationTable()

		try db.run(
			audio_recording_location.table.create(ifNotExists: true) { t in
				t.column(audio_recording_location.audioRecordingUUID)
				t.column(audio_recording_location.cell)
				t.column(audio_recording_location.index)
			}
		)
	}
}
