//
//  Query.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/20/25.
//
import SQLite
import SwiftUI

func InspectionUpsert(_ connection: SQLite.Connection, _ sID: UUID, _ inspection: Inspection) throws
{
	let upsert = schema.inspection.table.upsert(
		schema.inspection.comments <- SQLite.Expression<String>(inspection.comments ?? ""),
		schema.inspection.condition
			<- SQLite.Expression<String>(inspection.condition ?? ""),
		schema.inspection.created <- SQLite.Expression<Date>(value: inspection.created),
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
				//fieldTechnician: row[schema.inspection.fieldTechnician],
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
					comments: row[schema.mosquitoSource.comments],
					created: row[schema.mosquitoSource.created],
					description: row[schema.mosquitoSource.description],
					id: row[schema.mosquitoSource.id],
					location: location,
					habitat: row[schema.mosquitoSource.habitat],
					inspections: inspections_by_id[
						row[schema.mosquitoSource.id]
					] ?? [],
					name: row[schema.mosquitoSource.name],
					treatments: treatments_by_id[row[schema.mosquitoSource.id]]
						?? [],
					useType: row[schema.mosquitoSource.useType],
					waterOrigin: row[schema.mosquitoSource.waterOrigin]
				)
			)
		)
	}
	return results
}

func MosquitoSourceUpsert(connection: SQLite.Connection, _ source: MosquitoSource) throws {
	let upsert = schema.mosquitoSource.table.upsert(
		schema.mosquitoSource.access <- SQLite.Expression<String>(source.access),
		schema.mosquitoSource.comments <- SQLite.Expression<String>(source.comments),
		schema.mosquitoSource.created <- SQLite.Expression<Date>(value: source.created),
		schema.mosquitoSource.description <- SQLite.Expression<String>(source.description),
		schema.mosquitoSource.id <- SQLite.Expression<UUID>(value: source.id),
		schema.mosquitoSource.habitat <- SQLite.Expression<String>(source.habitat),
		schema.mosquitoSource.name <- SQLite.Expression<String>(source.name),
		schema.mosquitoSource.useType <- SQLite.Expression<String>(source.useType),
		schema.mosquitoSource.waterOrigin <- SQLite.Expression<String>(source.waterOrigin),
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
					city: row[schema.serviceRequest.city],
					created: created,
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
		schema.serviceRequest.city <- SQLite.Expression<String>(serviceRequest.city),
		schema.serviceRequest.created
			<- SQLite.Expression<Date>(value: serviceRequest.created),
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
		schema.treatment.id <- SQLite.Expression<UUID>(value: treatment.id),
		schema.treatment.habitat <- SQLite.Expression<String>(treatment.habitat),
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
