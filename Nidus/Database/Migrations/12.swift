import Foundation
import SQLite
import SQLiteMigrationManager

/// Make the audio recording table have a version and a UUID so that we can track changes
struct Migration12: Migration {
	var version: Int64 = 2025_08_29_0858_0000

	class NoteSummaryByHex {
		let table = Table("note_summary_by_hex")

		let cell = SQLite.Expression<UInt64>("cell")
		let cellResolution = SQLite.Expression<Int>("cell_resolution")
		let noteCount = SQLite.Expression<Int>("note_count")
		let noteType = SQLite.Expression<String>("note_type")
	}

	func migrateDatabase(_ db: Connection) throws {
		let note_summary = Migration12.NoteSummaryByHex()

		try db.run(
			note_summary.table.create(ifNotExists: false) { t in
				t.column(note_summary.cell)
				t.column(note_summary.cellResolution)
				t.column(note_summary.noteCount)
				t.column(note_summary.noteType)
				t.primaryKey(note_summary.cell, note_summary.noteType)
			}
		)
	}
}
