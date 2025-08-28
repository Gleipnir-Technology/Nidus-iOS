import Foundation
import OSLog
import SQLite

func NoteAudioNeedingUpload(_ connection: Connection) throws -> [AudioNote] {
	return try AudioNoteFromRow(
		connection: connection,
		query: schema.audioRecording.table.filter(schema.audioRecording.uploaded == nil)
	)
}

func NoteAudioInsert(
	_ connection: SQLite.Connection,
	_ audioNote: AudioNote
) throws {
	let insert = schema.audioRecording.table.insert(
		schema.audioRecording.created
			<- SQLite.Expression<Date>(value: audioNote.created),
		schema.audioRecording.duration
			<- SQLite.Expression<TimeInterval>(value: audioNote.duration),
		schema.audioRecording.transcription
			<- SQLite.Expression<String?>(value: audioNote.transcription),
		schema.audioRecording.transcriptionUserEdited
			<- SQLite.Expression<Bool>(value: audioNote.transcriptionUserEdited),
		schema.audioRecording.uuid <- SQLite.Expression<UUID>(value: audioNote.id),
		schema.audioRecording.version <- SQLite.Expression<Int>(value: audioNote.version)
	)
	try connection.run(insert)
	for (i, breadcrumb) in audioNote.breadcrumbs.enumerated() {
		let location_insert = schema.audioRecordingLocation.table.insert(
			schema.audioRecordingLocation.audioRecordingUUID
				<- SQLite.Expression<UUID>(value: audioNote.id),
			schema.audioRecordingLocation.cell
				<- SQLite.Expression<UInt64>(value: breadcrumb.cell),
			schema.audioRecordingLocation.created
				<- SQLite.Expression<Date>(value: breadcrumb.created),
			schema.audioRecordingLocation.index <- SQLite.Expression<Int>(value: i)
		)
		try connection.run(location_insert)
	}
	Logger.background.info(
		"Saved \(audioNote.breadcrumbs.count) locations for recording \(audioNote.id)"
	)
}

func NoteAudioUpdate(_ connection: Connection, _ uuid: UUID, transcription: String? = nil) throws {
	// Get the previous row
	let previousRowQuery = schema.audioRecording.table.where(
		schema.audioRecording.uuid == uuid
	).order(schema.audioRecording.version)
	let previous = try AudioNoteFromRow(connection: connection, query: previousRowQuery).first!

	let updated = AudioNote(
		id: previous.id,
		breadcrumbs: previous.breadcrumbs,
		created: previous.created,
		duration: previous.duration,
		transcription: transcription,
		transcriptionUserEdited: true,
		version: previous.version + 1
	)
	try NoteAudioInsert(connection, updated)
}

func NoteAudioUploaded(_ connection: Connection, _ uuid: UUID, uploaded: Date) throws -> Int {
	let query = schema.audioRecording.table.filter(
		SQLite.Expression<UUID>(value: uuid) == schema.audioRecording.uuid
	).update(
		schema.audioRecording.uploaded <- uploaded
	)
	return try connection.run(query)
}

func AudioRecordingAsNotes(
	_ connection: SQLite.Connection
) throws -> [AudioNote] {
	return try AudioNoteFromRow(connection: connection, query: schema.audioRecording.table)
}

func AudioRecordingLocations(
	_ connection: SQLite.Connection,
	_ audio_ids: [UUID]
) throws -> [UUID: [AudioNoteBreadcrumb]] {
	var results: [UUID: [AudioNoteBreadcrumb]] = [:]
	let query = schema.audioRecordingLocation.table.filter(
		audio_ids.contains(schema.audioRecordingLocation.audioRecordingUUID)
	).order(schema.audioRecordingLocation.index)
	for row in try connection.prepare(query) {
		results[row[schema.audioRecordingLocation.audioRecordingUUID], default: []].append(
			AudioNoteBreadcrumb(
				cell: row[schema.audioRecordingLocation.cell],
				created: row[schema.audioRecordingLocation.created]
			)
		)
	}
	return results
}

func AudioRecordingUpsert(
	_ connection: SQLite.Connection,
	_ audioNote: AudioNote,
	_ noteUUID: UUID
) throws {
	let upsert = schema.audioRecording.table.upsert(
		schema.audioRecording.created
			<- SQLite.Expression<Date>(value: audioNote.created),
		schema.audioRecording.duration
			<- SQLite.Expression<TimeInterval>(value: audioNote.duration),
		schema.audioRecording.transcription
			<- SQLite.Expression<String?>(value: audioNote.transcription),
		//schema.audioRecording.noteUUID <- SQLite.Expression<UUID>(value: noteUUID),
		schema.audioRecording.uuid <- SQLite.Expression<UUID>(value: audioNote.id),
		onConflictOf: schema.audioRecording.uuid
	)
	try connection.run(upsert)
}

func AudioUploaded(_ connection: SQLite.Connection, _ uuid: UUID) throws {
	let update = schema.audioRecording.table.filter(
		SQLite.Expression<UUID>(value: uuid) == schema.audioRecording.uuid
	).update(
		schema.audioRecording.uploaded <- Date.now
	)
	try connection.run(update)
}
