//
//  Database.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/31/25.
//
import MapKit
import OSLog
import SQLite
import SwiftUI

class InspectionTable {
	let table = Table("inspection")

	let comments = SQLite.Expression<String>("comments")
	let condition = SQLite.Expression<String>("condition")
	let created = SQLite.Expression<Date>("created")
	let id = SQLite.Expression<UUID>("id")
	let sourceID = SQLite.Expression<UUID>("source_id")

	func createTable(_ connection: SQLite.Connection) throws {
		try connection.run(
			table.create(ifNotExists: true) { t in
				t.column(id, primaryKey: true)
				t.column(comments)
				t.column(condition)
				t.column(created)
				t.column(sourceID)
			}
		)
	}

	func upsert(_ connection: SQLite.Connection, _ sID: UUID, _ inspection: Inspection) throws {
		let upsert = table.upsert(
			comments <- SQLite.Expression<String>(inspection.comments ?? ""),
			condition <- SQLite.Expression<String>(inspection.condition ?? ""),
			created <- SQLite.Expression<Date>(value: inspection.created),
			id <- SQLite.Expression<UUID>(value: inspection.id),
			sourceID <- SQLite.Expression<UUID>(value: sID),
			onConflictOf: id
		)
		try connection.run(upsert)
	}
}

class MosquitoSourceTable {
	let table = Table("mosquito_source")

	let access = SQLite.Expression<String>("access")
	let comments = SQLite.Expression<String>("comments")
	let created = SQLite.Expression<Date>("created")
	let description = SQLite.Expression<String>("description")
	let id = SQLite.Expression<UUID>("id")
	let habitat = SQLite.Expression<String>("habitat")
	let name = SQLite.Expression<String>("name")
	let useType = SQLite.Expression<String>("use_type")
	let waterOrigin = SQLite.Expression<String>("water_origin")
	let latitude = SQLite.Expression<Double>("latitude")
	let longitude = SQLite.Expression<Double>("longitude")

	func createTable(_ connection: SQLite.Connection) throws {
		try connection.run(
			table.create(ifNotExists: true) { t in
				t.column(id, primaryKey: true)
				t.column(access)
				t.column(comments)
				t.column(created)
				t.column(description)
				t.column(habitat)
				t.column(name)
				t.column(useType)
				t.column(waterOrigin)
				t.column(latitude)
				t.column(longitude)
			}
		)
	}
	func asNotes(
		_ connection: Connection,
		_ inspectionTable: InspectionTable,
		_ treatmentTable: TreatmentTable
	) throws -> [AnyNote] {
		var results: [AnyNote] = []
		var inspections_by_id: [UUID: [Inspection]] = [:]
		for row in try connection.prepare(inspectionTable.table) {
			inspections_by_id[row[inspectionTable.sourceID], default: []].append(
				Inspection(
					comments: row[inspectionTable.comments],
					condition: row[inspectionTable.condition],
					created: row[inspectionTable.created],
					id: row[inspectionTable.id]
				)
			)
		}
		var treatments_by_id: [UUID: [Treatment]] = [:]
		for row in try connection.prepare(treatmentTable.table) {
			treatments_by_id[row[treatmentTable.sourceID], default: []].append(
				Treatment(
					comments: row[treatmentTable.comments],
					created: row[treatmentTable.created],
					habitat: row[treatmentTable.habitat],
					id: row[treatmentTable.id],
					product: row[treatmentTable.product],
					quantity: row[treatmentTable.quantity],
					quantityUnit: row[treatmentTable.quantityUnit],
					siteCondition: row[treatmentTable.siteCondition],
					treatAcres: row[treatmentTable.treatAcres],
					treatHectares: row[treatmentTable.treatHectares]
				)
			)
		}
		for row in try connection.prepare(table) {
			let location = Location(latitude: row[latitude], longitude: row[longitude])
			results.append(
				AnyNote(
					MosquitoSource(
						access: row[access],
						comments: row[comments],
						created: row[created],
						description: row[description],
						id: row[id],
						location: location,
						habitat: row[habitat],
						inspections: inspections_by_id[row[id]] ?? [],
						name: row[name],
						treatments: treatments_by_id[row[id]] ?? [],
						useType: row[useType],
						waterOrigin: row[waterOrigin]
					)
				)
			)
		}
		return results
	}
	func upsert(connection: SQLite.Connection, _ source: MosquitoSource) throws {
		let upsert = table.upsert(
			access <- SQLite.Expression<String>(source.access),
			comments <- SQLite.Expression<String>(source.comments),
			created <- SQLite.Expression<Date>(value: source.created),
			description <- SQLite.Expression<String>(source.description),
			id <- SQLite.Expression<UUID>(value: source.id),
			habitat <- SQLite.Expression<String>(source.habitat),
			name <- SQLite.Expression<String>(source.name),
			useType <- SQLite.Expression<String>(source.useType),
			waterOrigin <- SQLite.Expression<String>(source.waterOrigin),
			latitude
				<- SQLite.Expression<Double>(
					value: source.location.latitude
				),
			longitude
				<- SQLite.Expression<Double>(
					value: source.location.longitude
				),
			onConflictOf: id
		)
		try connection.run(upsert)
	}
}
class ServiceRequestTable {
	let table = Table("service_request")

	let address = SQLite.Expression<String>("address")
	let city = SQLite.Expression<String>("city")
	let created = SQLite.Expression<Date>("created")
	let id = SQLite.Expression<UUID>("id")
	let priority = SQLite.Expression<String>("priority")
	let source = SQLite.Expression<String>("source")
	let status = SQLite.Expression<String>("status")
	let target = SQLite.Expression<String>("target")
	let zip = SQLite.Expression<String>("zip")
	let latitude = SQLite.Expression<Double>("latitude")
	let longitude = SQLite.Expression<Double>("longitude")

	func createTable(_ connection: SQLite.Connection) throws {
		try connection.run(
			table.create(ifNotExists: true) { t in
				t.column(id, primaryKey: true)
				t.column(address)
				t.column(city)
				t.column(created)
				t.column(priority)
				t.column(source)
				t.column(status)
				t.column(target)
				t.column(zip)
				t.column(latitude)
				t.column(longitude)
			}
		)
	}

	func asNotes(_ connection: Connection) throws -> [AnyNote] {
		var results: [AnyNote] = []
		for row in try connection.prepare(table) {
			let created = row[created]
			let location = Location(latitude: row[latitude], longitude: row[longitude])
			results.append(
				AnyNote(
					ServiceRequest(
						address: row[address],
						city: row[city],
						created: created,
						id: row[id],
						location: location,
						priority: row[priority],
						source: row[source],
						status: row[status],
						target: row[target],
						zip: row[zip]
					)
				)
			)
		}
		return results
	}
	func upsert(connection: SQLite.Connection, _ serviceRequest: ServiceRequest) throws {
		let upsert = table.upsert(
			address <- SQLite.Expression<String>(serviceRequest.address),
			city <- SQLite.Expression<String>(serviceRequest.city),
			created <- SQLite.Expression<Date>(value: serviceRequest.created),
			id <- SQLite.Expression<UUID>(value: serviceRequest.id),
			priority <- SQLite.Expression<String>(serviceRequest.priority),
			source <- SQLite.Expression<String>(serviceRequest.source),
			status <- SQLite.Expression<String>(serviceRequest.status),
			target <- SQLite.Expression<String>(serviceRequest.target),
			zip <- SQLite.Expression<String>(serviceRequest.zip),
			latitude
				<- SQLite.Expression<Double>(
					value: serviceRequest.location.latitude
				),
			longitude
				<- SQLite.Expression<Double>(
					value: serviceRequest.location.longitude
				),
			onConflictOf: id
		)
		try connection.run(upsert)
	}
}

class TreatmentTable {
	let table = Table("treatment")

	let comments = SQLite.Expression<String>("comments")
	let created = SQLite.Expression<Date>("created")
	let id = SQLite.Expression<UUID>("id")
	let habitat = SQLite.Expression<String>("habitat")
	let product = SQLite.Expression<String>("product")
	let quantity = SQLite.Expression<Double>("quantity")
	let quantityUnit = SQLite.Expression<String>("quantity_unit")
	let siteCondition = SQLite.Expression<String>("site_condition")
	let sourceID = SQLite.Expression<UUID>("source_id")
	let treatAcres = SQLite.Expression<Double>("treat_acres")
	let treatHectares = SQLite.Expression<Double>("treat_hectares")

	func createTable(_ connection: SQLite.Connection) throws {
		try connection.run(
			table.create(ifNotExists: true) { t in
				t.column(id, primaryKey: true)
				t.column(comments)
				t.column(created)
				t.column(habitat)
				t.column(product)
				t.column(quantity)
				t.column(quantityUnit)
				t.column(siteCondition)
				t.column(sourceID)
				t.column(treatAcres)
				t.column(treatHectares)
			}
		)
	}

	func upsert(_ connection: SQLite.Connection, _ sID: UUID, _ treatment: Treatment) throws {
		let upsert = table.upsert(
			comments <- SQLite.Expression<String>(treatment.comments),
			created <- SQLite.Expression<Date>(value: treatment.created),
			id <- SQLite.Expression<UUID>(value: treatment.id),
			habitat <- SQLite.Expression<String>(treatment.habitat),
			product <- SQLite.Expression<String>(treatment.product),
			quantity <- SQLite.Expression<Double>(value: treatment.quantity),
			quantityUnit <- SQLite.Expression<String>(treatment.quantityUnit),
			siteCondition <- SQLite.Expression<String>(treatment.siteCondition),
			sourceID <- SQLite.Expression<UUID>(value: sID),
			treatAcres <- SQLite.Expression<Double>(value: treatment.treatAcres),
			treatHectares <- SQLite.Expression<Double>(value: treatment.treatHectares),
			onConflictOf: id
		)
		try connection.run(upsert)
	}
}

class Database: ObservableObject {
	var center: CLLocation = CLLocation(
		latitude: MKCoordinateRegion.visalia.center.latitude,
		longitude: MKCoordinateRegion.visalia.center.longitude
	)
	var fileURL: URL?
	private var connection: SQLite.Connection?
	private var inspectionTable: InspectionTable = InspectionTable()
	private var mosquitoSourceTable: MosquitoSourceTable = MosquitoSourceTable()
	private var serviceRequestTable: ServiceRequestTable = ServiceRequestTable()
	private var treatmentTable: TreatmentTable = TreatmentTable()

	init() {
		do {
			fileURL = try FileManager.default.url(
				for: .applicationSupportDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: true
			).appendingPathComponent("fieldseeker.sqlite3")
			connection = try Connection(fileURL!.path)
			try inspectionTable.createTable(connection!)
			try mosquitoSourceTable.createTable(connection!)
			try serviceRequestTable.createTable(connection!)
			try treatmentTable.createTable(connection!)
		}
		catch {
			fileURL = nil
			Logger.background.log("Failed to initialize database file URL: \(error)")
		}
	}

	func notes() throws -> [UUID: AnyNote] {
		var results: [UUID: AnyNote] = [:]
		do {
			let sources = try mosquitoSourceTable.asNotes(
				connection!,
				inspectionTable,
				treatmentTable
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
			let requests = try serviceRequestTable.asNotes(connection!)
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
	func upsertServiceRequest(_ serviceRequest: ServiceRequest) throws {
		try self.serviceRequestTable.upsert(connection: self.connection!, serviceRequest)
	}
	func upsertSource(_ source: MosquitoSource) throws {
		try self.mosquitoSourceTable.upsert(connection: self.connection!, source)
		for inspection in source.inspections {
			try inspectionTable.upsert(self.connection!, source.id, inspection)
		}
		for treatment in source.treatments {
			try treatmentTable.upsert(self.connection!, source.id, treatment)
		}
	}
}
