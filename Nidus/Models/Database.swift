//
//  Database.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/31/25.
//
import OSLog
import SQLite
import SwiftUI

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
		var i = 0
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
			i += 1
			if i > 10 { break }
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

@Observable
class Database: ObservableObject {
	var fileURL: URL?
	private var connection: SQLite.Connection?
	private var serviceRequestTable: ServiceRequestTable
	var notes: [AnyNote] = []

	init() {
		serviceRequestTable = ServiceRequestTable()
		do {
			fileURL = try FileManager.default.url(
				for: .applicationSupportDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: true
			).appendingPathComponent("fieldseeker.sqlite3")
			connection = try Connection(fileURL!.path)
			try serviceRequestTable.createTable(connection!)
			triggerUpdateComplete()
		}
		catch {
			fileURL = nil
			Logger.background.log("Failed to initialize database file URL: \(error)")
		}
	}

	func upsertServiceRequest(_ serviceRequest: ServiceRequest) throws {
		try self.serviceRequestTable.upsert(connection: self.connection!, serviceRequest)
	}
	func triggerUpdateComplete() {
		do {
			notes = try serviceRequestTable.asNotes(connection!)
		}
		catch {
			Logger.background.error("Failed to get notes: \(error)")
		}
	}
}
