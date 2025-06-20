//
//  NidusDB.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/20/25.
//

import Foundation
import SQLite
import SQLiteMigrationManager

struct Migration1: Migration {
	var version: Int64 = 2025_06_20_1210_01234

	class InspectionTable {
		let table = Table("inspection")

		let comments = SQLite.Expression<String>("comments")
		let condition = SQLite.Expression<String>("condition")
		let created = SQLite.Expression<Date>("created")
		let fieldTechnician = SQLite.Expression<String>("field_technician")
		let id = SQLite.Expression<UUID>("id")
		let sourceID = SQLite.Expression<UUID>("source_id")
	}

	class MosquitoSourceTable {
		let table = Table("mosquito_source")

		let access = SQLite.Expression<String>("access")
		let active = SQLite.Expression<Bool?>("active")
		let comments = SQLite.Expression<String>("comments")
		let created = SQLite.Expression<Date>("created")
		let description = SQLite.Expression<String>("description")
		let id = SQLite.Expression<UUID>("id")
		let habitat = SQLite.Expression<String>("habitat")
		let lastInspectionDate = SQLite.Expression<Date>("last_inspection_date")
		let name = SQLite.Expression<String>("name")
		let nextActionDateScheduled = SQLite.Expression<Date>("next_action_date_scheduled")
		let useType = SQLite.Expression<String>("use_type")
		let waterOrigin = SQLite.Expression<String>("water_origin")
		let zone = SQLite.Expression<String>("zone")
		let latitude = SQLite.Expression<Double>("latitude")
		let longitude = SQLite.Expression<Double>("longitude")
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
	}

	class TreatmentTable {
		let table = Table("treatment")

		let comments = SQLite.Expression<String>("comments")
		let created = SQLite.Expression<Date>("created")
		let fieldTechnician = SQLite.Expression<String>("field_technician")
		let id = SQLite.Expression<UUID>("id")
		let habitat = SQLite.Expression<String>("habitat")
		let product = SQLite.Expression<String>("product")
		let quantity = SQLite.Expression<Double>("quantity")
		let quantityUnit = SQLite.Expression<String>("quantity_unit")
		let siteCondition = SQLite.Expression<String>("site_condition")
		let sourceID = SQLite.Expression<UUID>("source_id")
		let treatAcres = SQLite.Expression<Double>("treat_acres")
		let treatHectares = SQLite.Expression<Double>("treat_hectares")
	}

	func migrateDatabase(_ db: Connection) throws {

		let inspection = Migration1.InspectionTable()
		let mosquitoSource = Migration1.MosquitoSourceTable()
		let serviceRequest = Migration1.ServiceRequestTable()
		let treatment = Migration1.TreatmentTable()

		try db.run(
			inspection.table.create(ifNotExists: true) { t in
				t.column(inspection.comments)
				t.column(inspection.condition)
				t.column(inspection.created)
				t.column(inspection.fieldTechnician)
				t.column(inspection.id, primaryKey: true)
				t.column(inspection.sourceID)
			}
		)
		try db.run(
			mosquitoSource.table.create(ifNotExists: true) { t in
				t.column(mosquitoSource.access)
				t.column(mosquitoSource.active)
				t.column(mosquitoSource.comments)
				t.column(mosquitoSource.created)
				t.column(mosquitoSource.description)
				t.column(mosquitoSource.habitat)
				t.column(mosquitoSource.id, primaryKey: true)
				t.column(mosquitoSource.lastInspectionDate)
				t.column(mosquitoSource.name)
				t.column(mosquitoSource.nextActionDateScheduled)
				t.column(mosquitoSource.useType)
				t.column(mosquitoSource.waterOrigin)
				t.column(mosquitoSource.zone)
				t.column(mosquitoSource.latitude)
				t.column(mosquitoSource.longitude)
			}
		)
		try db.run(
			serviceRequest.table.create(ifNotExists: true) { t in
				t.column(serviceRequest.address)
				t.column(serviceRequest.assignedTechnician)
				t.column(serviceRequest.city)
				t.column(serviceRequest.created)
				t.column(serviceRequest.hasDog)
				t.column(serviceRequest.hasSpanishSpeaker)
				t.column(serviceRequest.id, primaryKey: true)
				t.column(serviceRequest.priority)
				t.column(serviceRequest.source)
				t.column(serviceRequest.status)
				t.column(serviceRequest.target)
				t.column(serviceRequest.zip)
				t.column(serviceRequest.latitude)
				t.column(serviceRequest.longitude)
			}
		)
		try db.run(
			treatment.table.create(ifNotExists: true) { t in
				t.column(treatment.comments)
				t.column(treatment.created)
				t.column(treatment.fieldTechnician)
				t.column(treatment.habitat)
				t.column(treatment.id, primaryKey: true)
				t.column(treatment.product)
				t.column(treatment.quantity)
				t.column(treatment.quantityUnit)
				t.column(treatment.siteCondition)
				t.column(treatment.sourceID)
				t.column(treatment.treatAcres)
				t.column(treatment.treatHectares)
			}
		)
	}
}
