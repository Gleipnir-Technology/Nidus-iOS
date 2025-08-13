import Foundation
import SQLite
import SQLiteMigrationManager

/// Remove "image" table and  create "picture" table instead, which contains mostly the same data, but is independent of the 'note' table.
struct Migration8: Migration {
	var version: Int64 = 2025_08_13_0500_0000

	/*
    class ImageTable {
        let table = Table("image")

        let created = SQLite.Expression<Date>("created")
        let deleted = SQLite.Expression<Date?>("deleted")
        let noteUUID = SQLite.Expression<UUID>("note_uuid")
        let uploaded = SQLite.Expression<Date?>("uploaded")
        let uuid = SQLite.Expression<UUID>("uuid")
    }
    */

	class PictureTable {
		let table = Table("picture")

		let created = SQLite.Expression<Date>("created")
		let deleted = SQLite.Expression<Date?>("deleted")
		let location = SQLite.Expression<UInt64?>("location")
		let uploaded = SQLite.Expression<Date?>("uploaded")
		let uuid = SQLite.Expression<UUID>("uuid")
	}

	func migrateDatabase(_ db: Connection) throws {
		let picture = Migration8.PictureTable()

		// Create the new table
		try db.run(
			picture.table.create(ifNotExists: true) { t in
				t.column(picture.created)
				t.column(picture.deleted)
				t.column(picture.location)
				t.column(picture.uploaded)
				t.column(picture.uuid)
			}
		)
		try db.execute(
			"INSERT INTO picture SELECT created, deleted, NULL, uploaded, uuid FROM image;"
		)
		// Clean up the old audio recording table from migration 6
		try db.execute(
			"DROP TABLE IF EXISTS _audio_recording_old"
		)
		try db.execute(
			"DROP TABLE IF EXISTS image"
		)
	}
}
