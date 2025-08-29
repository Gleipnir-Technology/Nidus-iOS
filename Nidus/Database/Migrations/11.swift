import Foundation
import SQLite
import SQLiteMigrationManager

/// Make the audio recording table have a version and a UUID so that we can track changes
struct Migration11: Migration {
	var version: Int64 = 2025_08_29_0845_0000

	func migrateDatabase(_ db: Connection) throws {

		try db.execute("DROP TABLE IF EXISTS note")
	}
}
