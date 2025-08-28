import Foundation
import SQLite

func PictureNoteFromRow(connection: Connection, query: QueryType) throws -> [PictureNote] {
	let rows = try connection.prepare(query)
	return rows.map { row in
		PictureNote(
			id: row[schema.picture.uuid],
			cell: row[schema.picture.location],
			created: row[schema.picture.created]
		)
	}
}
