import Foundation
import SQLite

func AudioNoteFromRow(connection: Connection, query: QueryType) throws -> [AudioNote] {
	let rows = try connection.prepare(query)
	let results = rows.map { row in
		AudioNote(
			id: row[schema.audioRecording.uuid],
			breadcrumbs: [],
			created: row[schema.audioRecording.created],
			duration: row[schema.audioRecording.duration],
			transcription: row[schema.audioRecording.transcription]
		)
	}
	let uuids = results.map { note in
		note.id
	}
	let locations_by_audio_id: [UUID: [AudioNoteBreadcrumb]] = try AudioRecordingLocations(
		connection,
		uuids
	)
	for result in results {
		result.breadcrumbs = locations_by_audio_id[result.id] ?? []
	}
	return results
}

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
