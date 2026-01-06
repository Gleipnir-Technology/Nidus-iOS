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
			Migration6(), Migration7(), Migration8(), Migration9(), Migration10(),
			Migration11(), Migration12(), Migration13(), Migration14(),
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
		return try NoteAudioNeedingUpload(connection)
	}

	func audioUploaded(_ uuid: UUID) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try AudioUploaded(connection, uuid)
	}

	func boundaryForNoteType(_ noteType: NoteType) throws -> Boundary {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try BoundaryForNoteType(connection, noteType)
	}

	func noteAudio(_ uuid: UUID) throws -> AudioNote? {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try NoteAudio(connection, uuid)
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
		try NoteAudioInsert(connection, recording)
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
			try migrationManager.createMigrationsTable()
		}

		if migrationManager.needsMigration() {
			try migrationManager.migrateDatabase()
		}
	}

	func noteAudioUpdate(_ note: AudioNote, transcription: String? = nil) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try NoteAudioUpdate(connection, note.id, transcription: transcription)
	}
	func noteAudioUploaded(_ note: AudioNote, uploaded: Date = Date.now) throws -> Int {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try NoteAudioUploaded(connection, note.id, uploaded: uploaded)
	}

	func notesByRegion(_ region: MKCoordinateRegion, types: Set<MapOverlay>) throws -> [UUID:
		any NoteProtocol]
	{
		var results: [UUID: any NoteProtocol] = [:]
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		if types.contains(.MosquitoSource) {
			let sources = try MosquitoSourceAsNotes(
				connection,
				region: region
			)
			for source in sources {
				results[source.id] = source
			}
		}
		if types.contains(.Note) {
			let audioRecording = try AudioRecordingAsNotes(connection)
			for ar in audioRecording {
				results[ar.id] = ar
			}
			let pictures = try PictureAsNotes(connection)
			for p in pictures {
				results[p.id] = p
			}
		}

		if types.contains(.ServiceRequest) {
			let serviceRequests = try ServiceRequestsAsNotes(
				connection,
				region: region
			)
			for s in serviceRequests {
				results[s.id] = s
			}
		}
		return results
	}

	func notesAudio() throws -> [AudioNote] {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try AudioRecordingAsNotes(connection)
	}

	func notesMosquitoSource() throws -> [MosquitoSourceNote] {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try MosquitoSourceAsNotes(
			connection,
			region: MKCoordinateRegion(
				center: .init(latitude: 0, longitude: 0),
				span: .init(latitudeDelta: 180, longitudeDelta: 360)
			)
		)
	}

	func notesPicture() throws -> [PictureNote] {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try PictureAsNotes(connection)
	}

	func notesCount() throws -> UInt {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		do {
			return try NotesCount(connection)
		}
	}

	func notesServiceRequest() throws -> [ServiceRequestNote] {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try ServiceRequestAsNotes(connection)
	}

	func noteSummaries(_ noteType: NoteType, _ cells: Set<H3Cell>) throws -> [NoteSummary] {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try NoteSummaryByHexAll(connection, cells: cells, noteType: noteType)
	}

	func noteSummaryByHexUpsert(
		cell: UInt64,
		cellResolution: UInt,
		count: Int,
		noteType: NoteType
	) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try NoteSummaryByHexUpsert(
			connection,
			cell: cell,
			cellResolution: cellResolution,
			noteCount: count,
			noteType: noteType
		)
	}

	func updateNotePicture(_ note: PictureNote, uploaded: Date) throws {
		guard let connection = connection else {
			throw DatabaseError.notConnected
		}
		return try PictureNoteUpdate(connection, note.id, uploaded: uploaded)
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
