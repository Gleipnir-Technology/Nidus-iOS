import H3
import MapKit
import OSLog
import SQLite
import SwiftUI

func NotePictureAllClearUploaded(_ connection: SQLite.Connection) throws {
	let update = schema.picture.table.update(
		schema.picture.uploaded <- nil
	)
	try connection.run(update)
}

func NotePictureDeleteAll(_ connection: SQLite.Connection) throws {
	let update = schema.audioRecording.table.update(
		schema.audioRecording.deleted <- Date()
	)
	try connection.run(update)
}

func PictureDelete(_ connection: SQLite.Connection, _ uuid: UUID) throws {
	let delete = schema.picture.table.filter(
		SQLite.Expression<UUID>(value: uuid) == schema.picture.uuid
	).update(
		schema.picture.deleted <- Date.now
	)
	try connection.run(delete)
}

func PictureInsert(_ connection: Connection, _ note: PictureNote) throws {
	let insert = schema.picture.table.insert(
		schema.picture.created
			<- SQLite.Expression<Date>(value: note.created),
		schema.picture.deleted
			<- SQLite.Expression<Date?>(value: nil),
		schema.picture.location
			<- SQLite.Expression<UInt64?>(value: note.cell),
		schema.picture.uploaded
			<- SQLite.Expression<Date?>(value: nil),
		schema.picture.uuid <- SQLite.Expression<UUID>(value: note.id)
	)
	try connection.run(insert)
}

func PicturesNeedingUpload(_ connection: Connection) throws -> [PictureNote] {
	// Query for notes where uploaded is NULL
	let query = schema.picture.table.filter(schema.picture.uploaded == nil)
	return try PictureNoteFromRow(connection: connection, query: query)
}

func PictureNoteUpdate(_ connection: Connection, _ uuid: UUID, uploaded: Date) throws {
	let update = schema.picture.table.filter(
		SQLite.Expression<UUID>(value: uuid) == schema.picture.uuid
	).update(
		schema.picture.uploaded <- uploaded
	)
	try connection.run(update)
}

func PictureAsNotes(
	_ connection: SQLite.Connection
) throws -> [PictureNote] {
	var results: [PictureNote] = []
	let query = schema.picture.table.filter(
		schema.picture.deleted == nil
	)
	let rows = try connection.prepare(query)
	for row in rows {
		results.append(
			PictureNote(
				id: row[schema.picture.uuid],
				cell: row[schema.picture.location],
				created: row[schema.picture.created]
			)
		)
	}
	return results
}

func PictureUploaded(_ connection: SQLite.Connection, _ uuid: UUID) throws {
	let update = schema.picture.table.filter(
		SQLite.Expression<UUID>(value: uuid) == schema.picture.uuid
	).update(
		schema.picture.uploaded <- Date.now
	)
	try connection.run(update)
}
