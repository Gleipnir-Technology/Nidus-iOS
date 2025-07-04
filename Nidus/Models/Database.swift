import MapKit
import OSLog
import SQLite
import SQLiteMigrationManager
import SwiftUI

class Database: ObservableObject {
	var center: CLLocation = CLLocation(
		latitude: MKCoordinateRegion.visalia.center.latitude,
		longitude: MKCoordinateRegion.visalia.center.longitude
	)
	private let connection: SQLite.Connection
	private let migrationManager: SQLiteMigrationManager

	init?() {
		do {
			self.connection = try Connection(Database.storeURL().absoluteString)
		}
		catch {
			return nil
		}
		self.migrationManager = SQLiteMigrationManager(
			db: self.connection,
			migrations: Database.migrations(),
			bundle: nil
		)
	}

	func audioThatNeedsUpload() throws -> [UUID] {
		return try AudioNeedingUpload(connection)
	}

	func audioUploaded(_ uuid: UUID) throws {
		return try AudioUploaded(connection, uuid)
	}

	func dropOriginalTables() throws {
		try self.connection.transaction {
			try self.connection.run("DROP TABLE IF EXISTS inspection")
			try self.connection.run("DROP TABLE IF EXISTS treatment")
			try self.connection.run("DROP TABLE IF EXISTS mosquito_source")
			try self.connection.run("DROP TABLE IF EXISTS service_request")
		}
	}

	func imagesThatNeedUpload() throws -> [UUID] {
		return try ImagesNeedingUpload(connection)
	}

	func imageUploaded(_ uuid: UUID) throws {
		try ImageUploaded(connection, uuid)
	}

	func migrateIfNeeded() throws {
		if !migrationManager.hasMigrationsTable() {
			// This can be removed after our initial testers (all 4 of them) have
			// this code run on their device.
			try dropOriginalTables()
			try migrationManager.createMigrationsTable()
		}

		if migrationManager.needsMigration() {
			try migrationManager.migrateDatabase()
		}
	}
	func notes() throws -> [UUID: AnyNote] {
		var results: [UUID: AnyNote] = [:]
		do {
			let sources = try MosquitoSourceAsNotes(
				connection
			)
			for source in sources {
				results[source.id] = source
			}
		}
		catch {
			Logger.background.error("Failed to get source notes: \(error)")
			throw error
		}
		do {
			let requests = try ServiceRequestAsNotes(connection)
			for request in requests {
				results[request.id] = request
			}
		}
		catch {
			Logger.background.error("Failed to get request notes: \(error)")
			throw error

		}
		do {
			let notes = try NativeNotesAll(connection)
			for note in notes {
				results[note.id] = note
			}
		}
		return results
	}

	func notesThatNeedUpload() throws -> [NidusNote] {
		return try NotesNeedingUpload(connection)
	}

	func noteUpdate(_ n: NidusNote) throws {
		return try NoteUpdate(connection, n)
	}

	func upsertNidusNote(_ note: NidusNote) throws -> Int64 {
		return try NoteUpsert(connection, note)
	}
	func upsertServiceRequest(_ serviceRequest: ServiceRequest) throws {
		try ServiceRequestUpsert(connection: self.connection, serviceRequest)
	}
	func upsertSource(_ source: MosquitoSource) throws {
		try MosquitoSourceUpsert(connection: self.connection, source)
		for inspection in source.inspections {
			try InspectionUpsert(self.connection, source.id, inspection)
		}
		for treatment in source.treatments {
			try TreatmentUpsert(self.connection, source.id, treatment)
		}
	}
}

extension Database {
	static func storeURL() -> URL {
		do {

			let supportURL = try FileManager.default.url(
				for: .applicationSupportDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: true
			)
			return supportURL.appendingPathComponent("fieldseeker.sqlite3")
		}
		catch {
			fatalError("could not get user documents directory URL: \(error)")
		}
	}

	static func migrations() -> [Migration] {
		return [Migration1(), Migration2(), Migration3()]
	}

	static func migrationsBundle() -> Bundle {
		guard
			let bundleURL = Bundle.main.url(
				forResource: "Migrations",
				withExtension: "bundle"
			)
		else {
			fatalError("could not find migrations bundle")
		}
		guard let bundle = Bundle(url: bundleURL) else {
			fatalError("could not load migrations bundle")
		}

		return bundle
	}
}

extension Database: CustomStringConvertible {
	var description: String {
		return "Database:\n" + "url: \(Database.storeURL().absoluteString)\n"
			+ "migration state:\n"
			+ "  hasMigrationsTable() \(migrationManager.hasMigrationsTable())\n"
			+ "  currentVersion()     \(migrationManager.currentVersion())\n"
			+ "  originVersion()      \(migrationManager.originVersion())\n"
			+ "  appliedVersions()    \(migrationManager.appliedVersions())\n"
			+ "  pendingMigrations()  \(migrationManager.pendingMigrations())\n"
			+ "  needsMigration()     \(migrationManager.needsMigration())"
	}
}
