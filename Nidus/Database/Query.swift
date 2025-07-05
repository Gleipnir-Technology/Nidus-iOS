//
//  Query.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/20/25.
//
import OSLog
import SQLite
import SwiftUI

func AudioNeedingUpload(_ connection: Connection) throws -> [UUID] {
	let query = schema.audioRecording.table.filter(schema.audioRecording.uploaded == nil)

	var uuids: [UUID] = []
	for audioRow in try connection.prepare(query) {
		let uuid = audioRow[schema.audioRecording.uuid]
		uuids.append(uuid)
	}
	return uuids
}

func AudioRecordingDeleteByNote(_ connection: SQLite.Connection, _ noteUUID: UUID) throws {
	let update = schema.audioRecording.table.filter(
		SQLite.Expression<UUID>(value: noteUUID) == schema.audioRecording.noteUUID
	).update(
		schema.audioRecording.deleted <- SQLite.Expression<Date>(value: Date.now),
		schema.audioRecording.uploaded <- nil
	)
	try connection.run(update)
}

func AudioRecordingUpsert(
	_ connection: SQLite.Connection,
	_ audio_recording: AudioRecording,
	_ noteUUID: UUID
) throws {
	let upsert = schema.audioRecording.table.upsert(
		schema.audioRecording.created
			<- SQLite.Expression<Date>(value: audio_recording.created),
		schema.audioRecording.duration
			<- SQLite.Expression<TimeInterval>(value: audio_recording.duration),
		schema.audioRecording.transcription
			<- SQLite.Expression<String?>(value: audio_recording.transcription),
		schema.audioRecording.noteUUID <- SQLite.Expression<UUID>(value: noteUUID),
		schema.audioRecording.uuid <- SQLite.Expression<UUID>(value: audio_recording.uuid),
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

func ImageDeleteByNote(_ connection: Connection, _ noteUUID: UUID) throws {
	let update = schema.image.table.filter(
		SQLite.Expression<UUID>(value: noteUUID) == schema.image.noteUUID
	).update(
		schema.image.deleted <- SQLite.Expression<Date>(value: Date.now),
		schema.image.uploaded <- nil
	)
	try connection.run(update)
}

func ImagesNeedingUpload(_ connection: Connection) throws -> [UUID] {
	// Query for notes where uploaded is NULL
	let query = schema.image.table.filter(schema.image.uploaded == nil)

	var uuids: [UUID] = []
	for imageRow in try connection.prepare(query) {
		let uuid = imageRow[schema.image.uuid]
		uuids.append(uuid)
	}
	return uuids
}

func ImageUploaded(_ connection: SQLite.Connection, _ uuid: UUID) throws {
	let update = schema.image.table.filter(
		SQLite.Expression<UUID>(value: uuid) == schema.image.uuid
	).update(
		schema.image.uploaded <- Date.now
	)
	try connection.run(update)
}

func InspectionUpsert(_ connection: SQLite.Connection, _ sID: UUID, _ inspection: Inspection) throws
{
	let upsert = schema.inspection.table.upsert(
		schema.inspection.comments <- SQLite.Expression<String>(inspection.comments ?? ""),
		schema.inspection.condition
			<- SQLite.Expression<String>(inspection.condition ?? ""),
		schema.inspection.created <- SQLite.Expression<Date>(value: inspection.created),
		schema.inspection.fieldTechnician
			<- SQLite.Expression<String>(value: inspection.fieldTechnician),
		schema.inspection.id <- SQLite.Expression<UUID>(value: inspection.id),
		schema.inspection.sourceID <- SQLite.Expression<UUID>(value: sID),
		onConflictOf: schema.inspection.id
	)
	try connection.run(upsert)
}

func MosquitoSourceAsNotes(
	_ connection: SQLite.Connection
) throws -> [AnyNote] {
	var results: [AnyNote] = []
	var inspections_by_id: [UUID: [Inspection]] = [:]
	for row in try connection.prepare(schema.inspection.table) {
		inspections_by_id[row[schema.inspection.sourceID], default: []].append(
			Inspection(
				comments: row[schema.inspection.comments],
				condition: row[schema.inspection.condition],
				created: row[schema.inspection.created],
				fieldTechnician: row[schema.inspection.fieldTechnician],
				id: row[schema.inspection.id]
			)
		)
	}
	var treatments_by_id: [UUID: [Treatment]] = [:]
	for row in try connection.prepare(schema.treatment.table) {
		treatments_by_id[row[schema.treatment.sourceID], default: []].append(
			Treatment(
				comments: row[schema.treatment.comments],
				created: row[schema.treatment.created],
				fieldTechnician: row[schema.treatment.fieldTechnician],
				habitat: row[schema.treatment.habitat],
				id: row[schema.treatment.id],
				product: row[schema.treatment.product],
				quantity: row[schema.treatment.quantity],
				quantityUnit: row[schema.treatment.quantityUnit],
				siteCondition: row[schema.treatment.siteCondition],
				treatAcres: row[schema.treatment.treatAcres],
				treatHectares: row[schema.treatment.treatHectares]
			)
		)
	}
	for row in try connection.prepare(schema.mosquitoSource.table) {
		let location = Location(
			latitude: row[schema.mosquitoSource.latitude],
			longitude: row[schema.mosquitoSource.longitude]
		)
		results.append(
			AnyNote(
				MosquitoSource(
					access: row[schema.mosquitoSource.access],
					active: row[schema.mosquitoSource.active],
					comments: row[schema.mosquitoSource.comments],
					created: row[schema.mosquitoSource.created],
					description: row[schema.mosquitoSource.description],
					habitat: row[schema.mosquitoSource.habitat],
					id: row[schema.mosquitoSource.id],
					inspections: inspections_by_id[
						row[schema.mosquitoSource.id]
					] ?? [],
					lastInspectionDate: row[
						schema.mosquitoSource.lastInspectionDate
					],
					location: location,
					name: row[schema.mosquitoSource.name],
					nextActionDateScheduled: row[
						schema.mosquitoSource.nextActionDateScheduled
					],
					treatments: treatments_by_id[row[schema.mosquitoSource.id]]
						?? [],
					useType: row[schema.mosquitoSource.useType],
					waterOrigin: row[schema.mosquitoSource.waterOrigin],
					zone: row[schema.mosquitoSource.zone]
				)
			)
		)
	}
	return results
}

func MosquitoSourceUpsert(connection: SQLite.Connection, _ source: MosquitoSource) throws {
	let upsert = schema.mosquitoSource.table.upsert(
		schema.mosquitoSource.access <- SQLite.Expression<String>(source.access),
		schema.mosquitoSource.active <- SQLite.Expression<Bool?>(value: source.active),
		schema.mosquitoSource.comments <- SQLite.Expression<String>(source.comments),
		schema.mosquitoSource.created <- SQLite.Expression<Date>(value: source.created),
		schema.mosquitoSource.description <- SQLite.Expression<String>(source.description),
		schema.mosquitoSource.habitat <- SQLite.Expression<String>(source.habitat),
		schema.mosquitoSource.id <- SQLite.Expression<UUID>(value: source.id),
		schema.mosquitoSource.lastInspectionDate
			<- SQLite.Expression<Date>(value: source.lastInspectionDate),
		schema.mosquitoSource.name <- SQLite.Expression<String>(source.name),
		schema.mosquitoSource.nextActionDateScheduled
			<- SQLite.Expression<Date>(value: source.nextActionDateScheduled),
		schema.mosquitoSource.useType <- SQLite.Expression<String>(source.useType),
		schema.mosquitoSource.waterOrigin <- SQLite.Expression<String>(source.waterOrigin),
		schema.mosquitoSource.zone <- SQLite.Expression<String>(source.zone),
		schema.mosquitoSource.latitude
			<- SQLite.Expression<Double>(
				value: source.location.latitude
			),
		schema.mosquitoSource.longitude
			<- SQLite.Expression<Double>(
				value: source.location.longitude
			),
		onConflictOf: schema.mosquitoSource.id
	)
	try connection.run(upsert)
}

func NativeNotesAll(_ connection: Connection) throws -> [AnyNote] {
	var results: [AnyNote] = []
	var audio_recordings_by_note_uuid: [UUID: [AudioRecording]] = [:]
	for row in try connection.prepare(schema.audioRecording.table) {
		audio_recordings_by_note_uuid[row[schema.audioRecording.noteUUID], default: []]
			.append(
				AudioRecording(
					created: row[schema.audioRecording.created],
					duration: row[schema.audioRecording.duration],
					transcription: row[schema.audioRecording.transcription],
					uuid: row[schema.audioRecording.uuid]
				)
			)
	}
	var image_by_note_uuid: [UUID: [NoteImage]] = [:]
	for row in try connection.prepare(schema.image.table) {
		image_by_note_uuid[row[schema.image.noteUUID], default: []].append(
			NoteImage(
				created: row[schema.image.created],
				uuid: row[schema.image.uuid]
			)
		)
	}
	let rows = try connection.prepare(
		schema.note.table.filter(
			SQLite.Expression<Date?>(value: nil) === schema.note.deleted
		)
	)
	for row in rows {
		let location = Location(
			latitude: row[schema.note.latitude],
			longitude: row[schema.note.longitude]
		)
		results.append(
			AnyNote(
				NidusNote(
					audioRecordings: audio_recordings_by_note_uuid[
						row[schema.note.uuid]
					] ?? [],
					images: image_by_note_uuid[row[schema.note.uuid]] ?? [],
					location: location,
					text: row[schema.note.text],
					uploaded: row[schema.note.uploaded],
					uuid: row[schema.note.uuid]
				)
			)
		)
	}
	return results
}

func NoteDelete(_ connection: SQLite.Connection, _ noteUUID: UUID) throws {
	let update = schema.note.table.filter(
		SQLite.Expression<UUID>(value: noteUUID) == schema.note.uuid
	).update(
		schema.note.deleted <- SQLite.Expression<Date?>(value: Date.now),
		schema.note.uploaded <- SQLite.Expression<Date?>(value: nil)
	)
	try connection.run(update)
}

func NoteImageDelete(_ connection: SQLite.Connection, _ noteUUID: UUID) throws {
	let delete = schema.image.table.filter(
		SQLite.Expression<UUID>(value: noteUUID) == schema.image.noteUUID
	).delete()
	try connection.run(delete)
}

func NoteImageUpsert(
	_ connection: SQLite.Connection,
	_ noteImage: NoteImage,
	_ noteUUID: UUID
) throws {
	let upsert = schema.image.table.upsert(
		schema.image.created <- SQLite.Expression<Date>(value: noteImage.created),
		schema.image.noteUUID <- SQLite.Expression<UUID>(value: noteUUID),
		schema.image.uuid <- SQLite.Expression<UUID>(value: noteImage.uuid),
		onConflictOf: schema.image.uuid
	)
	try connection.run(upsert)
}

func NotesNeedingUpload(_ connection: Connection) throws -> [NidusNote] {
	var notes: [NidusNote] = []

	// Query for notes where uploaded is NULL
	let query = schema.note.table.filter(schema.note.uploaded == nil)

	for noteRow in try connection.prepare(query) {
		let noteUUID = noteRow[schema.note.uuid]
		let timestamp = noteRow[schema.note.timestamp]
		let latitude = noteRow[schema.note.latitude]
		let longitude = noteRow[schema.note.longitude]
		let text = noteRow[schema.note.text]
		let uploaded = noteRow[schema.note.uploaded]

		// Create location from coordinates
		let location = Location(latitude: latitude, longitude: longitude)

		// Query for associated audio recordings
		var audioRecordings: [AudioRecording] = []
		let audioQuery = schema.audioRecording.table.filter(
			schema.audioRecording.noteUUID == noteUUID
		)

		for audioRow in try connection.prepare(audioQuery) {
			let audioRecording = AudioRecording(
				created: audioRow[schema.audioRecording.created],
				duration: audioRow[schema.audioRecording.duration],
				transcription: audioRow[schema.audioRecording.transcription],
				uuid: audioRow[schema.audioRecording.uuid]
			)
			audioRecordings.append(audioRecording)
		}

		// Query for associated images
		var images: [NoteImage] = []
		let imageQuery = schema.image.table.filter(schema.image.noteUUID == noteUUID)

		for imageRow in try connection.prepare(imageQuery) {
			let noteImage = NoteImage(
				created: imageRow[schema.image.created],
				uuid: imageRow[schema.image.uuid]
			)
			images.append(noteImage)
		}

		// Create the NidusNote with all associated data
		let nidusNote = NidusNote(
			audioRecordings: audioRecordings,
			images: images,
			location: location,
			text: text,
			uploaded: uploaded,
			uuid: noteUUID
		)

		// Set the timestamp to match the database value
		nidusNote.timestamp = timestamp

		notes.append(nidusNote)
	}

	return notes

}

func NoteUpdate(_ connection: Connection, _ n: NidusNote) throws {
	let update = schema.note.table.filter(
		SQLite.Expression<UUID>(value: n.id) == schema.note.uuid
	).update(
		schema.note.latitude <- n.location.latitude,
		schema.note.longitude <- n.location.longitude,
		schema.note.text <- n.text,
		schema.note.timestamp <- n.timestamp,
		schema.note.uploaded <- n.uploaded
	)
	try connection.run(update)
}

func NoteUpsert(_ connection: Connection, _ note: NidusNote) throws -> Int64 {
	try AudioRecordingDeleteByNote(connection, note.id)
	for audioRecording in note.audioRecordings {
		try AudioRecordingUpsert(connection, audioRecording, note.id)
	}
	try NoteImageDelete(connection, note.id)
	for noteImage in note.images {
		try NoteImageUpsert(connection, noteImage, note.id)
	}
	let upsert = schema.note.table.upsert(
		schema.note.latitude
			<- SQLite.Expression<Double>(
				value: note.location.latitude
			),
		schema.note.longitude
			<- SQLite.Expression<Double>(
				value: note.location.longitude
			),
		schema.note.text <- SQLite.Expression<String>(note.text),
		schema.note.timestamp <- SQLite.Expression<Date>(value: note.timestamp),
		schema.note.uuid <- SQLite.Expression<UUID>(value: note.id),
		onConflictOf: schema.note.uuid
	)
	Logger.foreground.info("Running note upsert \(upsert)")
	let result = try connection.run(upsert)
	Logger.foreground.info("Note upsert \(note.id) yielded row id \(result)")
	return result
}

func ServiceRequestAsNotes(_ connection: Connection) throws -> [AnyNote] {
	var results: [AnyNote] = []
	for row in try connection.prepare(schema.serviceRequest.table) {
		let created = row[schema.serviceRequest.created]
		let location = Location(
			latitude: row[schema.serviceRequest.latitude],
			longitude: row[schema.serviceRequest.longitude]
		)
		results.append(
			AnyNote(
				ServiceRequest(
					address: row[schema.serviceRequest.address],
					assignedTechnician: row[
						schema.serviceRequest.assignedTechnician
					],
					city: row[schema.serviceRequest.city],
					created: created,
					hasDog: row[schema.serviceRequest.hasDog],
					hasSpanishSpeaker: row[
						schema.serviceRequest.hasSpanishSpeaker
					],
					id: row[schema.serviceRequest.id],
					location: location,
					priority: row[schema.serviceRequest.priority],
					source: row[schema.serviceRequest.source],
					status: row[schema.serviceRequest.status],
					target: row[schema.serviceRequest.target],
					zip: row[schema.serviceRequest.zip]
				)
			)
		)
	}
	return results
}

func ServiceRequestUpsert(connection: SQLite.Connection, _ serviceRequest: ServiceRequest) throws {
	let upsert = schema.serviceRequest.table.upsert(
		schema.serviceRequest.address <- SQLite.Expression<String>(serviceRequest.address),
		schema.serviceRequest.assignedTechnician
			<- SQLite.Expression<String>(serviceRequest.assignedTechnician),
		schema.serviceRequest.city <- SQLite.Expression<String>(serviceRequest.city),
		schema.serviceRequest.created
			<- SQLite.Expression<Date>(value: serviceRequest.created),
		schema.serviceRequest.hasDog
			<- SQLite.Expression<Bool?>(value: serviceRequest.hasDog),
		schema.serviceRequest.hasSpanishSpeaker
			<- SQLite.Expression<Bool?>(value: serviceRequest.hasSpanishSpeaker),
		schema.serviceRequest.id <- SQLite.Expression<UUID>(value: serviceRequest.id),
		schema.serviceRequest.priority
			<- SQLite.Expression<String>(serviceRequest.priority),
		schema.serviceRequest.source <- SQLite.Expression<String>(serviceRequest.source),
		schema.serviceRequest.status <- SQLite.Expression<String>(serviceRequest.status),
		schema.serviceRequest.target <- SQLite.Expression<String>(serviceRequest.target),
		schema.serviceRequest.zip <- SQLite.Expression<String>(serviceRequest.zip),
		schema.serviceRequest.latitude
			<- SQLite.Expression<Double>(
				value: serviceRequest.location.latitude
			),
		schema.serviceRequest.longitude
			<- SQLite.Expression<Double>(
				value: serviceRequest.location.longitude
			),
		onConflictOf: schema.serviceRequest.id
	)
	try connection.run(upsert)
}

func TreatmentUpsert(_ connection: SQLite.Connection, _ sID: UUID, _ treatment: Treatment) throws {
	let upsert = schema.treatment.table.upsert(
		schema.treatment.comments <- SQLite.Expression<String>(treatment.comments),
		schema.treatment.created <- SQLite.Expression<Date>(value: treatment.created),
		schema.treatment.fieldTechnician
			<- SQLite.Expression<String>(value: treatment.fieldTechnician),
		schema.treatment.habitat <- SQLite.Expression<String>(treatment.habitat),
		schema.treatment.id <- SQLite.Expression<UUID>(value: treatment.id),
		schema.treatment.product <- SQLite.Expression<String>(treatment.product),
		schema.treatment.quantity <- SQLite.Expression<Double>(value: treatment.quantity),
		schema.treatment.quantityUnit <- SQLite.Expression<String>(treatment.quantityUnit),
		schema.treatment.siteCondition
			<- SQLite.Expression<String>(treatment.siteCondition),
		schema.treatment.sourceID <- SQLite.Expression<UUID>(value: sID),
		schema.treatment.treatAcres
			<- SQLite.Expression<Double>(value: treatment.treatAcres),
		schema.treatment.treatHectares
			<- SQLite.Expression<Double>(value: treatment.treatHectares),
		onConflictOf: schema.treatment.id
	)
	try connection.run(upsert)
}
