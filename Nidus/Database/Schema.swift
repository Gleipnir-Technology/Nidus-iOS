//
//  Schema.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/20/25.
//

import OSLog
import SQLite
import SwiftUI

struct DBSchema {
	let inspection = InspectionTable()
	let mosquitoSource = MosquitoSourceTable()
	let serviceRequest = ServiceRequestTable()
	let treatment = TreatmentTable()
}
var schema = DBSchema()

class InspectionTable {
	let table = Table("inspection")

	let comments = SQLite.Expression<String>("comments")
	let condition = SQLite.Expression<String>("condition")
	let created = SQLite.Expression<Date>("created")
	let id = SQLite.Expression<UUID>("id")
	let sourceID = SQLite.Expression<UUID>("source_id")

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

}
