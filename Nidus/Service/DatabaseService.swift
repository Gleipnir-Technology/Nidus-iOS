import MapKit
import OSLog
import SQLite
import SQLiteMigrationManager

private enum DatabaseError: Error {
	case notConnected
}

class DatabaseService: CustomStringConvertible {
	private var connection: SQLite.Connection? = nil
	private var migrationManager: SQLiteMigrationManager? = nil

	// MARK - static functions
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
		return [
			Migration1(), Migration2(), Migration3(), Migration4(), Migration5(),
			Migration6(), Migration7(), Migration8(), Migration9(),
		]
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

	// MARK - public calculated properties
	var description: String {
		/*let store: URL = DatabaseService.storeURL()
        return ("Database:\n" //"url: \(store.absoluteString)\n"
            + "migration state:\n"
            + "  hasMigrationsTable() \(migrationManager.hasMigrationsTable())\n"
            + "  currentVersion()     \(migrationManager.currentVersion())\n"
            + "  originVersion()      \(migrationManager.originVersion())\n"
            + "  appliedVersions()    \(migrationManager.appliedVersions())\n"
            + "  pendingMigrations()  \(migrationManager.pendingMigrations())\n"
            + "  needsMigration()     \(migrationManager.needsMigration())")*/
		return "lol, fix compiler timeout above"
	}

	// MARK - public interface
	func connect() throws {
		let connection = try Connection(DatabaseService.storeURL().absoluteString)
		self.connection = connection
		self.migrationManager = SQLiteMigrationManager(
			db: connection,
			migrations: DatabaseService.migrations(),
			bundle: nil
		)

	}

	func audioThatNeedsUpload() throws -> [AudioNote] {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try AudioNeedingUpload(connection)
	}

	func audioUploaded(_ uuid: UUID) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try AudioUploaded(connection, uuid)
	}

	func deleteNote(_ note: NidusNote) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		//try AudioRecordingDeleteByNote(connection, note.id)
		//try ImageDeleteByNote(connection, note.id)
		return try NoteDelete(connection, note.id)
	}

	func dropOriginalTables() throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		try connection.transaction {
			try connection.run("DROP TABLE IF EXISTS inspection")
			try connection.run("DROP TABLE IF EXISTS treatment")
			try connection.run("DROP TABLE IF EXISTS mosquito_source")
			try connection.run("DROP TABLE IF EXISTS service_request")
		}
	}

	func picturesThatNeedUpload() throws -> [PictureNote] {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try PicturesNeedingUpload(connection)
	}

	func pictureUploaded(_ uuid: UUID) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		try PictureUploaded(connection, uuid)
	}

	func insertAudioNote(_ recording: AudioNote) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		try AudioRecordingInsert(connection, recording)
	}

	func insertPictureNote(_ note: PictureNote) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		try PictureInsert(connection, note)
	}

	func migrateIfNeeded() throws {
		guard let migrationManager = migrationManager else {
			throw DatabaseError.notConnected
		}
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
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		/*do {
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
		}*/
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
		return results
	}
	func notesByRegion(_ region: MKCoordinateRegion) throws -> [UUID: any NoteProtocol] {
		var results: [UUID: any NoteProtocol] = [:]
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		let sources = try MosquitoSourceAsNotes(
			connection,
			region: region
		)
		for source in sources {
			results[source.id] = source
		}
		let audioRecording = try AudioRecordingAsNotes(connection)
		for ar in audioRecording {
			results[ar.id] = ar
		}
		let pictures = try PictureAsNotes(connection)
		for p in pictures {
			results[p.id] = p
		}
		return results
	}

	func notesCount() throws -> Int {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		do {
			return try NotesCount(connection)
		}
	}

	func noteUpdate(_ n: NidusNote) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try NoteUpdate(connection, n)
	}

	func updateNoteAudio(_ note: AudioNote, uploaded: Date) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try AudioNoteUpdate(connection, note.id, uploaded: uploaded)
	}

	func updateNotePicture(_ note: PictureNote, uploaded: Date) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try PictureNoteUpdate(connection, note.id, uploaded: uploaded)
	}

	func upsertNidusNote(_ note: NidusNote) throws -> Int64 {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try NoteUpsert(connection, note)
	}
	func upsertServiceRequest(_ serviceRequest: ServiceRequest) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		try ServiceRequestUpsert(connection: connection, serviceRequest)
	}
	func upsertSource(_ source: MosquitoSource) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		try MosquitoSourceUpsert(connection: connection, source)
		for inspection in source.inspections {
			try InspectionUpsert(connection, source.id, inspection)
		}
		for treatment in source.treatments {
			try TreatmentUpsert(connection, source.id, treatment)
		}
	}
}
