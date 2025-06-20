import MapKit
import OSLog
import SQLite
import SwiftUI

class Database: ObservableObject {
	var center: CLLocation = CLLocation(
		latitude: MKCoordinateRegion.visalia.center.latitude,
		longitude: MKCoordinateRegion.visalia.center.longitude
	)
	var fileURL: URL?
	private var connection: SQLite.Connection?

	init() {
		fileURL = nil
	}

	func connect() throws {
		fileURL = try FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		).appendingPathComponent("fieldseeker.sqlite3")
		self.connection = try Connection(fileURL!.path)
		try handleDatabaseMigrations(connection!)
	}

	func notes() throws -> [UUID: AnyNote] {
		var results: [UUID: AnyNote] = [:]
		do {
			let sources = try MosquitoSourceAsNotes(
				connection!
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
			let requests = try ServiceRequestAsNotes(connection!)
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
		try ServiceRequestUpsert(connection: self.connection!, serviceRequest)
	}
	func upsertSource(_ source: MosquitoSource) throws {
		try MosquitoSourceUpsert(connection: self.connection!, source)
		for inspection in source.inspections {
			try InspectionUpsert(self.connection!, source.id, inspection)
		}
		for treatment in source.treatments {
			try TreatmentUpsert(self.connection!, source.id, treatment)
		}
	}
}
