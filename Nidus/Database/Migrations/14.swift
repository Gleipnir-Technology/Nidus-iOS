import Foundation
import SQLite
import SQLiteMigrationManager

/// Add a field for whether or not the location value was manually selected
struct Migration14: Migration {
	var version: Int64 = 2026_01_06_1023_0000

	class MosquitoSourceTable {
		let table = Table("mosquito_source")

		let access = SQLite.Expression<String>("access")
		let active = SQLite.Expression<Bool?>("active")
		let comments = SQLite.Expression<String>("comments")
		let created = SQLite.Expression<Date>("created")
		let description = SQLite.Expression<String>("description")
		let habitat = SQLite.Expression<String>("habitat")
		let id = SQLite.Expression<UUID>("id")
		let lastInspectionDate = SQLite.Expression<Date>("last_inspection_date")
		let name = SQLite.Expression<String>("name")
		let nextActionDateScheduled = SQLite.Expression<Date>("next_action_date_scheduled")
		let useType = SQLite.Expression<String>("use_type")
		let waterOrigin = SQLite.Expression<String>("water_origin")
		let zone = SQLite.Expression<String>("zone")

		let latitude = SQLite.Expression<Double>("latitude")
		let longitude = SQLite.Expression<Double>("longitude")

		// Adding
		let h3cell = SQLite.Expression<UInt64>("h3cell")
	}

	class ServiceRequestTable {
		let table = Table("service_request")

		let address = SQLite.Expression<String>("address")
		let assignedTechnician = SQLite.Expression<String>("assigned_technician")
		let city = SQLite.Expression<String>("city")
		let created = SQLite.Expression<Date>("created")
		let hasDog = SQLite.Expression<Bool?>("has_dog")
		let hasSpanishSpeaker = SQLite.Expression<Bool?>("has_spanish_speaker")
		let id = SQLite.Expression<UUID>("id")
		let priority = SQLite.Expression<String>("priority")
		let source = SQLite.Expression<String>("source")
		let status = SQLite.Expression<String>("status")
		let target = SQLite.Expression<String>("target")
		let zip = SQLite.Expression<String>("zip")

		let latitude = SQLite.Expression<Double>("latitude")
		let longitude = SQLite.Expression<Double>("longitude")

		// Adding
		let h3cell = SQLite.Expression<UInt64>("h3cell")
	}

	func migrateDatabase(_ db: Connection) throws {
		let schemaChanger = SchemaChanger(connection: db)
		try schemaChanger.alter(table: "mosquito_source") { table in
			let h3cellColumn = ColumnDefinition(
				name: "h3cell",
				type: .BLOB,
				nullable: false,
				defaultValue: .blobLiteral(""),
			)
			table.add(column: h3cellColumn)
		}
		try schemaChanger.alter(table: "service_request") { table in
			let h3cellColumn = ColumnDefinition(
				name: "h3cell",
				type: .BLOB,
				nullable: false,
				defaultValue: .blobLiteral(""),
			)
			table.add(column: h3cellColumn)
		}
	}
}
