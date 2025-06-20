//
//  Migration-1.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/20/25.
//
import SQLite

func CreateInspectionTable(_ connection: SQLite.Connection) throws {
	try connection.run(
		schema.inspection.table.create(ifNotExists: true) { t in
			t.column(schema.inspection.id, primaryKey: true)
			t.column(schema.inspection.comments)
			t.column(schema.inspection.condition)
			t.column(schema.inspection.created)
			t.column(schema.inspection.sourceID)
		}
	)
}

func CreateMosquitoSourceTable(_ connection: SQLite.Connection) throws {
	try connection.run(
		schema.mosquitoSource.table.create(ifNotExists: true) { t in
			t.column(schema.mosquitoSource.id, primaryKey: true)
			t.column(schema.mosquitoSource.access)
			t.column(schema.mosquitoSource.comments)
			t.column(schema.mosquitoSource.created)
			t.column(schema.mosquitoSource.description)
			t.column(schema.mosquitoSource.habitat)
			t.column(schema.mosquitoSource.name)
			t.column(schema.mosquitoSource.useType)
			t.column(schema.mosquitoSource.waterOrigin)
			t.column(schema.mosquitoSource.latitude)
			t.column(schema.mosquitoSource.longitude)
		}
	)
}
func CreateServiceRequestTable(_ connection: SQLite.Connection) throws {
	try connection.run(
		schema.serviceRequest.table.create(ifNotExists: true) { t in
			t.column(schema.serviceRequest.id, primaryKey: true)
			t.column(schema.serviceRequest.address)
			t.column(schema.serviceRequest.city)
			t.column(schema.serviceRequest.created)
			t.column(schema.serviceRequest.priority)
			t.column(schema.serviceRequest.source)
			t.column(schema.serviceRequest.status)
			t.column(schema.serviceRequest.target)
			t.column(schema.serviceRequest.zip)
			t.column(schema.serviceRequest.latitude)
			t.column(schema.serviceRequest.longitude)
		}
	)
}

func CreateTreatmentTable(_ connection: SQLite.Connection) throws {
	try connection.run(
		schema.treatment.table.create(ifNotExists: true) { t in
			t.column(schema.treatment.id, primaryKey: true)
			t.column(schema.treatment.comments)
			t.column(schema.treatment.created)
			t.column(schema.treatment.habitat)
			t.column(schema.treatment.product)
			t.column(schema.treatment.quantity)
			t.column(schema.treatment.quantityUnit)
			t.column(schema.treatment.siteCondition)
			t.column(schema.treatment.sourceID)
			t.column(schema.treatment.treatAcres)
			t.column(schema.treatment.treatHectares)
		}
	)
}
func handleDatabaseMigrations(_ connection: SQLite.Connection) throws {
	try CreateInspectionTable(connection)
	try CreateMosquitoSourceTable(connection)
	try CreateServiceRequestTable(connection)
	try CreateTreatmentTable(connection)
}
