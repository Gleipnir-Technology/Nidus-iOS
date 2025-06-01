//
//  FieldSeeker.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/30/25.
//
import CoreData
import Foundation
import MapKit
import SwiftUI

final class Inspection: Codable, Equatable, Hashable, Identifiable {
	enum CodingKeys: CodingKey {
		case comments
		case condition
		case created
		case id
	}
	var comments: String?
	var condition: String?
	var created: Date
	var id: UUID

	init(comments: String? = nil, condition: String? = nil, created: Date, id: UUID) {
		self.comments = comments
		self.condition = condition
		self.created = created
		self.id = id
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		comments = try container.decodeIfPresent(String.self, forKey: .comments)
		condition = try container.decodeIfPresent(String.self, forKey: .condition)
		created = try container.decode(Date.self, forKey: .created)
		id = try container.decode(UUID.self, forKey: .id)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(comments, forKey: .comments)
		try container.encode(condition, forKey: .condition)
		try container.encode(created, forKey: .created)
		try container.encode(id, forKey: .id)
	}
	static func == (lhs: Inspection, rhs: Inspection) -> Bool {
		return lhs.comments == rhs.comments && lhs.created == rhs.created
			&& lhs.condition == rhs.condition
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(comments)
		hasher.combine(condition)
		hasher.combine(created)
	}
}

final class Location: Codable, Equatable, Hashable, Identifiable {
	enum CodingKeys: CodingKey {
		case latitude
		case longitude
	}
	var latitude: Double
	var longitude: Double

	init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		latitude = try container.decode(Double.self, forKey: .latitude)
		longitude = try container.decode(Double.self, forKey: .longitude)
	}

	func coordinate() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(latitude, forKey: .latitude)
		try container.encode(longitude, forKey: .longitude)
	}
	static func == (lhs: Location, rhs: Location) -> Bool {
		return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(latitude)
		hasher.combine(longitude)
	}
}

final class MosquitoSource: Codable, Identifiable, Note {
	enum CodingKeys: CodingKey {
		case access
		case comments
		case created
		case description
		case id
		case location
		case habitat
		case inspections
		case name
		case treatments
		case useType
		case waterOrigin
	}
	var access: String
	var comments: String
	var created: Date
	var description: String
	var id: UUID
	var location: Location
	var habitat: String
	var inspections: [Inspection]
	var name: String
	var treatments: [Treatment]
	var useType: String
	var waterOrigin: String

	// Note protocol
	var category: NoteCategory { NoteCategory.byNameOrDefault(categoryName) }
	var categoryName: String { "Mosquito Source" }
	var color: Color { category.color }
	var content: String { name }
	var coordinate: CLLocationCoordinate2D {
		get {
			location.coordinate()
		}
		set {
			location.latitude = newValue.latitude
			location.longitude = newValue.longitude
		}
	}
	var timestamp: Date { created }
	// end Note protocol

	init(
		access: String,
		comments: String,
		created: Date,
		description: String,
		id: UUID,
		location: Location,
		habitat: String,
		inspections: [Inspection],
		name: String,
		treatments: [Treatment],
		useType: String,
		waterOrigin: String
	) {
		self.access = access
		self.comments = comments
		self.created = created
		self.description = description
		self.id = id
		self.location = location
		self.habitat = habitat
		self.inspections = inspections
		self.name = name
		self.treatments = treatments
		self.useType = useType
		self.waterOrigin = waterOrigin
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		access = try container.decode(String.self, forKey: .access)
		comments = try container.decode(String.self, forKey: .comments)
		created = try container.decode(Date.self, forKey: .created)
		description = try container.decode(String.self, forKey: .description)
		id = try container.decode(UUID.self, forKey: .id)
		location = try container.decode(Location.self, forKey: .location)
		habitat = try container.decode(String.self, forKey: .habitat)
		inspections = try container.decode([Inspection].self, forKey: .inspections)
		name = try container.decode(String.self, forKey: .name)
		treatments = try container.decode([Treatment].self, forKey: .treatments)
		useType = try container.decode(String.self, forKey: .useType)
		waterOrigin = try container.decode(String.self, forKey: .waterOrigin)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(access, forKey: .access)
		try container.encode(comments, forKey: .comments)
		try container.encode(created, forKey: .created)
		try container.encode(description, forKey: .description)
		try container.encode(id, forKey: .id)
		try container.encode(location, forKey: .location)
		try container.encode(inspections, forKey: .inspections)
		try container.encode(name, forKey: .name)
		try container.encode(treatments, forKey: .treatments)
		try container.encode(useType, forKey: .useType)
		try container.encode(waterOrigin, forKey: .waterOrigin)
	}
	static func == (lhs: MosquitoSource, rhs: MosquitoSource) -> Bool {
		return lhs.access == rhs.access && lhs.comments == rhs.comments
			&& lhs.created == rhs.created && lhs.description == rhs.description
			&& lhs.location == rhs.location && lhs.habitat == rhs.habitat
			&& lhs.inspections == rhs.inspections && lhs.name == rhs.name
			&& lhs.treatments == rhs.treatments && lhs.useType == rhs.useType
			&& lhs.waterOrigin == rhs.waterOrigin
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(access)
		hasher.combine(comments)
		hasher.combine(created)
		hasher.combine(description)
		hasher.combine(location)
		hasher.combine(habitat)
		hasher.combine(inspections)
		hasher.combine(name)
		hasher.combine(treatments)
		hasher.combine(useType)
		hasher.combine(waterOrigin)
	}
}

final class ServiceRequest: Codable, Identifiable, Note {
	enum CodingKeys: CodingKey {
		case address
		case city
		case created
		case id
		case location
		case priority
		case source
		case status
		case target
		case zip
	}
	var address: String
	var city: String
	var created: Date
	var id: UUID
	var location: Location
	var priority: String
	var source: String
	var status: String
	var target: String
	var zip: String

	// Note protocol
	var category: NoteCategory { NoteCategory.byNameOrDefault(categoryName) }
	var categoryName: String { "Service Request" }
	var color: Color { category.color }
	var content: String { address }
	var coordinate: CLLocationCoordinate2D {
		get { location.coordinate() }
		set {
			location.latitude = newValue.latitude
			location.longitude = newValue.longitude
		}
	}
	var timestamp: Date { created }
	// end Note protocol
	init(
		address: String,
		city: String,
		created: Date,
		id: UUID,
		location: Location,
		priority: String,
		source: String,
		status: String,
		target: String,
		zip: String
	) {
		self.address = address
		self.city = city
		self.created = created
		self.id = id
		self.location = location
		self.priority = priority
		self.source = source
		self.status = status
		self.target = target
		self.zip = zip
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		address = try container.decode(String.self, forKey: .address)
		city = try container.decode(String.self, forKey: .city)
		created = try container.decode(Date.self, forKey: .created)
		id = try container.decode(UUID.self, forKey: .id)
		location = try container.decode(Location.self, forKey: .location)
		priority = try container.decode(String.self, forKey: .priority)
		source = try container.decode(String.self, forKey: .source)
		status = try container.decode(String.self, forKey: .status)
		target = try container.decode(String.self, forKey: .target)
		zip = try container.decode(String.self, forKey: .zip)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(address, forKey: .address)
		try container.encode(city, forKey: .city)
		try container.encode(created, forKey: .created)
		try container.encode(id, forKey: .id)
		try container.encode(location, forKey: .location)
		try container.encode(priority, forKey: .priority)
		try container.encode(source, forKey: .source)
		try container.encode(status, forKey: .status)
		try container.encode(target, forKey: .target)
		try container.encode(zip, forKey: .zip)
	}
	static func == (lhs: ServiceRequest, rhs: ServiceRequest) -> Bool {
		return lhs.address == rhs.address && lhs.city == rhs.city
			&& lhs.created == rhs.created && lhs.location == rhs.location
			&& lhs.priority == rhs.priority && lhs.source == rhs.source
			&& lhs.status == rhs.status && lhs.target == rhs.target
			&& lhs.zip == rhs.zip
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(address)
		hasher.combine(city)
		hasher.combine(created)
		hasher.combine(location)
		hasher.combine(priority)
		hasher.combine(source)
		hasher.combine(status)
		hasher.combine(target)
		hasher.combine(zip)
	}
}

final class TrapData: Codable, Identifiable, Note {
	enum CodingKeys: CodingKey {
		case created
		case description
		case id
		case location
		case name
	}
	var created: Date
	var description: String
	var id: UUID
	var location: Location
	var name: String

	// Note protocol
	var category: NoteCategory { NoteCategory.byNameOrDefault(categoryName) }
	var categoryName: String { "Trap Data" }
	var color: Color { category.color }
	var content: String { name }
	var coordinate: CLLocationCoordinate2D {
		get {
			location.coordinate()
		}
		set {
			location.latitude = newValue.latitude
			location.longitude = newValue.longitude
		}
	}
	var timestamp: Date { created }
	// end Note protocol

	init(created: Date, description: String, id: UUID, location: Location, name: String) {
		self.created = created
		self.description = description
		self.id = id
		self.location = location
		self.name = name
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		created = try container.decode(Date.self, forKey: .created)
		description = try container.decode(String.self, forKey: .description)
		id = try container.decode(UUID.self, forKey: .id)
		location = try container.decode(Location.self, forKey: .location)
		name = try container.decode(String.self, forKey: .name)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(created, forKey: .created)
		try container.encode(description, forKey: .description)
		try container.encode(id, forKey: .id)
		try container.encode(location, forKey: .location)
		try container.encode(name, forKey: .name)
	}
	static func == (lhs: TrapData, rhs: TrapData) -> Bool {
		return lhs.created == rhs.created && lhs.description == rhs.description
			&& lhs.location == rhs.location && lhs.name == rhs.name
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(created)
		hasher.combine(description)
		hasher.combine(location)
		hasher.combine(name)
	}
}
final class Treatment: Codable, Equatable, Hashable, Identifiable {
	enum CodingKeys: CodingKey {
		case comments
		case created
		case habitat
		case id
		case product
		case quantity
		case quantityUnit
		case siteCondition
		case treatAcres
		case treatHectares
	}

	var comments: String
	var created: Date
	var habitat: String
	var id: UUID
	var product: String
	var quantity: Double
	var quantityUnit: String
	var siteCondition: String
	var treatAcres: Double
	var treatHectares: Double

	init(
		comments: String,
		created: Date,
		habitat: String,
		id: UUID,
		product: String,
		quantity: Double,
		quantityUnit: String,
		siteCondition: String,
		treatAcres: Double,
		treatHectares: Double
	) {
		self.comments = comments
		self.created = created
		self.habitat = habitat
		self.id = id
		self.product = product
		self.quantity = quantity
		self.quantityUnit = quantityUnit
		self.siteCondition = siteCondition
		self.treatAcres = treatAcres
		self.treatHectares = treatHectares
	}

	required init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		comments = try container.decode(String.self, forKey: .comments)
		created = try container.decode(Date.self, forKey: .created)
		habitat = try container.decode(String.self, forKey: .habitat)
		id = try container.decode(UUID.self, forKey: .id)
		product = try container.decode(String.self, forKey: .product)
		quantity = try container.decode(Double.self, forKey: .quantity)
		quantityUnit = try container.decode(String.self, forKey: .quantityUnit)
		siteCondition = try container.decode(String.self, forKey: .siteCondition)
		treatAcres = try container.decode(Double.self, forKey: .treatAcres)
		treatHectares = try container.decode(Double.self, forKey: .treatHectares)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(comments, forKey: .comments)
		try container.encode(created, forKey: .created)
		try container.encode(habitat, forKey: .habitat)
		try container.encode(product, forKey: .product)
		try container.encode(quantity, forKey: .quantity)
		try container.encode(quantityUnit, forKey: .quantityUnit)
		try container.encode(siteCondition, forKey: .siteCondition)
		try container.encode(treatAcres, forKey: .treatAcres)
		try container.encode(treatHectares, forKey: .treatHectares)
	}
	static func == (lhs: Treatment, rhs: Treatment) -> Bool {
		return lhs.comments == rhs.comments && lhs.created == rhs.created
			&& lhs.habitat == rhs.habitat && lhs.product == rhs.product
			&& lhs.quantity == rhs.quantity && lhs.quantityUnit == rhs.quantityUnit
			&& lhs.siteCondition == rhs.siteCondition
			&& lhs.treatAcres == rhs.treatAcres
			&& lhs.treatHectares == rhs.treatHectares
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(comments)
		hasher.combine(created)
		hasher.combine(habitat)
		hasher.combine(product)
		hasher.combine(quantity)
		hasher.combine(quantityUnit)
		hasher.combine(siteCondition)
		hasher.combine(treatAcres)
		hasher.combine(treatHectares)
	}
}
