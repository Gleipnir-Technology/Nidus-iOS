import H3
import MapKit
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

/*func AudioRecordingDeleteByNote(_ connection: SQLite.Connection, _ noteUUID: UUID) throws {
	let update = schema.audioRecording.table.filter(
		SQLite.Expression<UUID>(value: noteUUID) == schema.audioRecording.noteUUID
	).update(
		schema.audioRecording.deleted <- SQLite.Expression<Date>(value: Date.now),
		schema.audioRecording.uploaded <- nil
	)
	try connection.run(update)
}*/

func AudioRecordingAsNotes(
	_ connection: SQLite.Connection
) throws -> [AudioNote] {
	//let start = Date.now
	var results: [AudioNote] = []
	let query = schema.audioRecording.table
	let rows = try connection.prepare(query)
	//let audio_ids = rows.map { $0[schema.audioRecording.uuid] }
	let audio_ids: [UUID] = []
	let locations_by_audio_id: [UUID: [H3Cell]] = try AudioRecordingLocations(
		connection,
		audio_ids
	)
	for row in rows {
		results.append(
			AudioNote(
				id: row[schema.audioRecording.uuid],
				locations: locations_by_audio_id[row[schema.audioRecording.uuid]]
					?? [],
				//locations: [],
				timestamp: row[schema.audioRecording.created],
				transcription: row[schema.audioRecording.transcription]
			)
		)
	}
	//let end = Date.now
	//Logger.background.info(
	//"Took \(end.timeIntervalSince(start)) seconds to load audio recordings as notes"
	//)
	return results
}

func AudioRecordingInsert(
	_ connection: SQLite.Connection,
	_ audio_recording: AudioRecording
) throws {
	let insert = schema.audioRecording.table.insert(
		schema.audioRecording.created
			<- SQLite.Expression<Date>(value: audio_recording.created),
		schema.audioRecording.duration
			<- SQLite.Expression<TimeInterval>(value: audio_recording.duration),
		schema.audioRecording.transcription
			<- SQLite.Expression<String?>(value: audio_recording.transcription),
		schema.audioRecording.uuid <- SQLite.Expression<UUID>(value: audio_recording.uuid)
	)
	try connection.run(insert)
	for (i, cell) in audio_recording.locations.enumerated() {
		let location_insert = schema.audioRecordingLocation.table.insert(
			schema.audioRecordingLocation.audioRecordingUUID
				<- SQLite.Expression<UUID>(value: audio_recording.uuid),
			schema.audioRecordingLocation.cell
				<- SQLite.Expression<UInt64>(value: cell),
			schema.audioRecordingLocation.index <- SQLite.Expression<Int>(value: i)
		)
		try connection.run(location_insert)
	}
	Logger.background.info(
		"Saved \(audio_recording.locations.count) locations for recording \(audio_recording.uuid)"
	)
}

func AudioRecordingLocations(
	_ connection: SQLite.Connection,
	_ audio_ids: [UUID]
) throws -> [UUID: [H3Cell]] {
	var results: [UUID: [H3Cell]] = [:]
	// TODO: this was causing crashes, so now I'm just querying all of the locations
	//let query = schema.audioRecordingLocation.table.filter(
	//audio_ids.contains(schema.audioRecordingLocation.audioRecordingUUID)
	//).order(schema.audioRecordingLocation.index)
	let query = schema.audioRecordingLocation.table.order(schema.audioRecordingLocation.index)
	for row in try connection.prepare(query) {
		results[row[schema.audioRecordingLocation.audioRecordingUUID], default: []].append(
			row[schema.audioRecordingLocation.cell]
		)
	}
	//Logger.background.info(
	//"Pulled \(results.count) audio locations for \(audio_ids.count) audio recordings"
	//)
	return results
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
		//schema.audioRecording.noteUUID <- SQLite.Expression<UUID>(value: noteUUID),
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

func InspectionsForSources(_ connection: SQLite.Connection, _ sourceUUIDs: [UUID]) throws -> [UUID:
	[Inspection]]
{
	//let start = Date.now
	var results: [UUID: [Inspection]] = [:]
	let query = schema.inspection.table.filter(
		sourceUUIDs.contains(schema.inspection.sourceID)
	)
	for row in try connection.prepare(query) {
		results[row[schema.inspection.sourceID], default: []].append(
			Inspection(
				comments: row[schema.inspection.comments],
				condition: row[schema.inspection.condition],
				created: row[schema.inspection.created],
				fieldTechnician: row[schema.inspection.fieldTechnician],
				id: row[schema.inspection.id]
			)
		)
	}
	//let end = Date.now
	//Logger.background.info("Inspection query took \(end.timeIntervalSince(start)) seconds")
	return results
}

func TreatmentsForSources(_ connection: SQLite.Connection, _ sourceUUIDs: [UUID]) throws -> [UUID:
	[Treatment]]
{
	//let start = Date.now
	var results: [UUID: [Treatment]] = [:]
	let query = schema.treatment.table.filter(
		sourceUUIDs.contains(schema.treatment.sourceID)
	)
	for row in try connection.prepare(query) {
		results[row[schema.treatment.sourceID], default: []].append(
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
	//let end = Date.now
	//Logger.background.info("Treatment query took \(end.timeIntervalSince(start)) seconds")
	return results
}

func MosquitoSourceAsNotes(
	_ connection: SQLite.Connection,
	region: MKCoordinateRegion
) throws -> [MosquitoSourceNote] {
	//let start = Date.now
	var results: [MosquitoSourceNote] = []
	let query = schema.mosquitoSource.table.filter(
		SQLite.Expression(value: region.maxLatitude) >= schema.mosquitoSource.latitude
	).filter(
		SQLite.Expression(value: region.minLatitude) <= schema.mosquitoSource.latitude
	).filter(
		SQLite.Expression(value: region.maxLongitude) >= schema.mosquitoSource.longitude
	).filter(
		SQLite.Expression(value: region.minLongitude) <= schema.mosquitoSource.longitude
	)
	// Get all of the source IDs so we can get the inspections and treatments
	let rows = try connection.prepare(query)
	let source_ids = rows.map { $0[schema.mosquitoSource.id] }
	let inspections_by_id = try InspectionsForSources(connection, source_ids)
	let treatments_by_id = try TreatmentsForSources(connection, source_ids)
	for row in try connection.prepare(query) {
		let latLng: CLLocationCoordinate2D = CLLocationCoordinate2D(
			latitude: Double(row[schema.mosquitoSource.latitude]),
			longitude: Double(row[schema.mosquitoSource.longitude])
		)
		let cell = try latLngToCell(latLng: latLng, resolution: 15)
		results.append(
			MosquitoSourceNote(
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
				location: cell,
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
	}
	//let end = Date.now
	//Logger.background.info("Source query took \(end.timeIntervalSince(start)) seconds")
	return results
	/*
	for row in try connection.prepare(schema.mosquitoSource.table) {
		let location = Location(
			latitude: row[schema.mosquitoSource.latitude],
			longitude: row[schema.mosquitoSource.longitude]
		)
		results.append(
			AnyNote(
				MosquitoSource(
				)
			)
		)
	}
	return results
     */
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

func NotesCount(_ connection: SQLite.Connection) throws -> Int {
	let result = try connection.scalar(schema.inspection.table.count)
	return result
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
	//try AudioRecordingDeleteByNote(connection, note.id)
	for audioRecording in note.audioRecordings {
		try AudioRecordingUpsert(connection, audioRecording, note.id)
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

func PictureAsNotes(
	_ connection: SQLite.Connection
) throws -> [PictureNote] {
	//let start = Date.now
	var results: [PictureNote] = []
	let query = schema.picture.table.filter(
		schema.picture.deleted == nil
	)
	let rows = try connection.prepare(query)
	for row in rows {
		results.append(
			PictureNote(
				id: row[schema.picture.uuid],
				location: row[schema.picture.location],
				timestamp: row[schema.picture.created]
			)
		)
	}
	//let end = Date.now
	//Logger.background.info(
	//"Took \(end.timeIntervalSince(start)) seconds to load pictures as notes"
	//)
	return results
}

func PictureDelete(_ connection: SQLite.Connection, _ uuid: UUID) throws {
	let delete = schema.picture.table.filter(
		SQLite.Expression<UUID>(value: uuid) == schema.picture.uuid
	).update(
		schema.picture.deleted <- Date.now
	)
	try connection.run(delete)
}

func PictureInsert(_ connection: Connection, uuid: UUID, location: H3Cell?, created: Date) throws {
	let insert = schema.picture.table.insert(
		schema.picture.created
			<- SQLite.Expression<Date>(value: created),
		schema.picture.deleted
			<- SQLite.Expression<Date?>(value: nil),
		schema.picture.location
			<- SQLite.Expression<UInt64?>(value: location),
		schema.picture.uploaded
			<- SQLite.Expression<Date?>(value: nil),
		schema.picture.uuid <- SQLite.Expression<UUID>(value: uuid)
	)
	try connection.run(insert)
}

func PicturesNeedingUpload(_ connection: Connection) throws -> [UUID] {
	// Query for notes where uploaded is NULL
	let query = schema.picture.table.filter(schema.picture.uploaded == nil)

	var uuids: [UUID] = []
	for row in try connection.prepare(query) {
		let uuid = row[schema.picture.uuid]
		uuids.append(uuid)
	}
	return uuids
}

func PictureUploaded(_ connection: SQLite.Connection, _ uuid: UUID) throws {
	let update = schema.picture.table.filter(
		SQLite.Expression<UUID>(value: uuid) == schema.picture.uuid
	).update(
		schema.picture.uploaded <- Date.now
	)
	try connection.run(update)
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
