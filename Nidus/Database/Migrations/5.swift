import Foundation
import SQLite
import SQLiteMigrationManager

struct Migration5: Migration {
	var version: Int64 = 2025_07_04_2120_0000

	class NoteTable {
		let table = Table("note")

		let created = SQLite.Expression<Date?>("created")
		let due = SQLite.Expression<Date?>("due")
	}

	func migrateDatabase(_ db: Connection) throws {
		let note = Migration5.NoteTable()

		try db.run(
			note.table.addColumn(note.created)
		)
		try db.run(
			note.table.addColumn(note.due)
		)
	}
}
