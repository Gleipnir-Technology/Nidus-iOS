//
//  FieldSeeker.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/30/25.
//
import Foundation
import SwiftData

@Model
final class Inspection: Identifiable {
	var comments: String?
	var condition: String?
	var created: Date

	init(comments: String? = nil, condition: String? = nil, created: Date) {
		self.comments = comments
		self.condition = condition
		self.created = created
	}
}

@Model
final class Location: Identifiable {
	var latitude: Double
	var longitude: Double

	init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
}

@Model
final class MosquitoSource: Identifiable {
	var access: String?
	var comments: String?
	var description_: String?
	var location: Location
	var habitat: String?
	var inspections: [Inspection]
	var name: String?
	var treatments: [Treatment]
	var useType: String?
	var waterOrigin: String?

	init(
		access: String? = nil,
		comments: String? = nil,
		description: String? = nil,
		location: Location,
		habitat: String? = nil,
		inspections: [Inspection],
		name: String? = nil,
		treatments: [Treatment],
		useType: String? = nil,
		waterOrigin: String? = nil
	) {
		self.access = access
		self.comments = comments
		self.description_ = description
		self.location = location
		self.habitat = habitat
		self.inspections = inspections
		self.name = name
		self.treatments = treatments
		self.useType = useType
		self.waterOrigin = waterOrigin
	}
}

@Model
final class Treatment: Identifiable {
	var comments: String?
	var created: Date
	var habitat: String?
	var product: String?
	var quantity: Double?
	var quantityUnit: String?
	var siteCondition: String?
	var treatAcres: Double?
	var treatHectares: Double?

	init(
		comments: String? = nil,
		created: Date,
		habitat: String? = nil,
		product: String? = nil,
		quantity: Double? = nil,
		quantityUnit: String? = nil,
		siteCondition: String? = nil,
		treatAcres: Double? = nil,
		treatHectares: Double? = nil
	) {
		self.comments = comments
		self.created = created
		self.habitat = habitat
		self.product = product
		self.quantity = quantity
		self.quantityUnit = quantityUnit
		self.siteCondition = siteCondition
		self.treatAcres = treatAcres
		self.treatHectares = treatHectares
	}
}
