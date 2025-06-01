//
//  Database.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/31/25.
//
import OSLog
import SQLite
import SwiftUI

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
	func asNotes(_ connection: Connection) throws -> [AnyNote] {
		var results: [AnyNote] = []
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
						inspections: [],
						name: row[name],
						treatments: [],
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

@Observable
class Database: ObservableObject {
	var fileURL: URL?
	private var connection: SQLite.Connection?
	private var mosquitoSourceTable: MosquitoSourceTable = MosquitoSourceTable()
	private var serviceRequestTable: ServiceRequestTable = ServiceRequestTable()
	var notes: [AnyNote] = []
	var minx: Double?
	var miny: Double?
	var maxx: Double?
	var maxy: Double?
	var cluster: NotesCluster = NotesCluster()

	init() {
		do {
			fileURL = try FileManager.default.url(
				for: .applicationSupportDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: true
			).appendingPathComponent("fieldseeker.sqlite3")
			connection = try Connection(fileURL!.path)
			try mosquitoSourceTable.createTable(connection!)
			try serviceRequestTable.createTable(connection!)
			triggerUpdateComplete()
		}
		catch {
			fileURL = nil
			Logger.background.log("Failed to initialize database file URL: \(error)")
		}
	}

	var notesToShow: [AnyNote] {
		var toShow: [AnyNote] = []
		if minx == nil || miny == nil || maxx == nil || maxy == nil {
			if notes.isEmpty {
				return []
			}
			return Array(notes[0..<10])
		}
		for note in notes {
			if note.coordinate.latitude > miny! && note.coordinate.longitude > minx!
				&& note.coordinate.latitude < maxy!
				&& note.coordinate.longitude < maxx!
			{
				toShow.append(note)
			}
		}
		return toShow
	}

	func setPosition(_ minX: Double?, _ minY: Double?, _ maxX: Double?, _ maxY: Double?) {
		self.minx = minX
		self.miny = minY
		self.maxx = maxX
		self.maxy = maxY
		Logger.foreground.info(
			"Set DB limits to \(String(describing: minX)), \(String(describing: minY)), \(String(describing: maxX)), \(String(describing: maxY))"
		)
	}
	func upsertServiceRequest(_ serviceRequest: ServiceRequest) throws {
		try self.serviceRequestTable.upsert(connection: self.connection!, serviceRequest)
	}
	func upsertSource(_ source: MosquitoSource) throws {
		try self.mosquitoSourceTable.upsert(connection: self.connection!, source)
	}
	func triggerUpdateComplete() {
		do {
			notes = []
			notes += try mosquitoSourceTable.asNotes(connection!)
			notes += try serviceRequestTable.asNotes(connection!)
			Task {
				await cluster.addNotes(notes)
			}
		}
		catch {
			Logger.background.error("Failed to get notes: \(error)")
		}
	}
}
