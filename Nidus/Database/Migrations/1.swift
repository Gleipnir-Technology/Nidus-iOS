//
//  NidusDB.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/20/25.
//

import Foundation
import SQLite
import SQLiteMigrationManager

struct Migration1: Migration {
	var version: Int64 = 2025_06_20_1210_01234

	func migrateDatabase(_ db: Connection) throws {
	}
}
