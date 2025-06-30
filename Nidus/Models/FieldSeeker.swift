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
		case actionTaken
		case comments
		case condition
		case created
		case fieldTechnician
		case id
		case locationName
		case siteCondition
	}
	var actionTaken: String?
	var comments: String?
	var condition: String?
	var created: Date
	var fieldTechnician: String
	var id: UUID
	var locationName: String?
	var siteCondition: String?

	init(
		actionTaken: String? = nil,
		comments: String? = nil,
		condition: String? = nil,
		created: Date,
		fieldTechnician: String = "",
		id: UUID,
		locationName: String? = nil,
		siteCondition: String? = nil
	) {
		self.actionTaken = actionTaken
		self.comments = comments
		self.condition = condition
		self.created = created
		self.fieldTechnician = fieldTechnician
		self.id = id
		self.locationName = locationName
		self.siteCondition = siteCondition
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		actionTaken = try container.decodeIfPresent(String.self, forKey: .actionTaken)
		comments = try container.decodeIfPresent(String.self, forKey: .comments)
		condition = try container.decodeIfPresent(String.self, forKey: .condition)
		created = try container.decode(Date.self, forKey: .created)
		fieldTechnician = try container.decode(String.self, forKey: .fieldTechnician)
		id = try container.decode(UUID.self, forKey: .id)
		locationName = try container.decode(String.self, forKey: .locationName)
		siteCondition = try container.decode(String.self, forKey: .siteCondition)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(actionTaken, forKey: .actionTaken)
		try container.encode(comments, forKey: .comments)
		try container.encode(condition, forKey: .condition)
		try container.encode(created, forKey: .created)
		try container.encode(fieldTechnician, forKey: .fieldTechnician)
		try container.encode(id, forKey: .id)
		try container.encode(locationName, forKey: .locationName)
		try container.encode(siteCondition, forKey: .siteCondition)
	}
	static func == (lhs: Inspection, rhs: Inspection) -> Bool {
		return lhs.actionTaken == rhs.actionTaken && lhs.comments == rhs.comments
			&& lhs.condition == rhs.condition && lhs.created == rhs.created
			&& lhs.fieldTechnician == rhs.fieldTechnician
			&& lhs.locationName == rhs.locationName
			&& lhs.siteCondition == rhs.siteCondition
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(actionTaken)
		hasher.combine(comments)
		hasher.combine(condition)
		hasher.combine(created)
		hasher.combine(fieldTechnician)
		hasher.combine(locationName)
		hasher.combine(siteCondition)
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
	init(_ location: CLLocation) {
		self.latitude = location.coordinate.latitude
		self.longitude = location.coordinate.longitude
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
	public static var visalia: Location {
		.init(
			CLLocation(
				latitude: 36.326,
				longitude: -119.313191
			)
		)
	}
}

final class MosquitoSource: Codable, Identifiable, Note {
	enum CodingKeys: CodingKey {
		case access
		case active
		case comments
		case created
		case description
		case habitat
		case id
		case inspections
		case lastInspectionDate
		case location
		case name
		case nextActionDateScheduled
		case treatments
		case useType
		case waterOrigin
		case zone
	}
	var access: String
	var active: Bool?
	var comments: String
	var created: Date
	var description: String
	var habitat: String
	var id: UUID
	var inspections: [Inspection]
	var lastInspectionDate: Date
	var location: Location
	var name: String
	var nextActionDateScheduled: Date
	var treatments: [Treatment]
	var useType: String
	var waterOrigin: String
	var zone: String

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
		active: Bool?,
		comments: String,
		created: Date,
		description: String,
		habitat: String,
		id: UUID,
		inspections: [Inspection],
		lastInspectionDate: Date,
		location: Location,
		name: String,
		nextActionDateScheduled: Date,
		treatments: [Treatment],
		useType: String,
		waterOrigin: String,
		zone: String
	) {
		self.access = access
		self.active = active
		self.comments = comments
		self.created = created
		self.description = description
		self.habitat = habitat
		self.id = id
		self.inspections = inspections
		self.lastInspectionDate = lastInspectionDate
		self.location = location
		self.name = name
		self.nextActionDateScheduled = nextActionDateScheduled
		self.treatments = treatments
		self.useType = useType
		self.waterOrigin = waterOrigin
		self.zone = zone
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		access = try container.decode(String.self, forKey: .access)
		active = try container.decode(Bool.self, forKey: .active)
		comments = try container.decode(String.self, forKey: .comments)
		created = try container.decode(Date.self, forKey: .created)
		description = try container.decode(String.self, forKey: .description)
		habitat = try container.decode(String.self, forKey: .habitat)
		id = try container.decode(UUID.self, forKey: .id)
		inspections = try container.decode([Inspection].self, forKey: .inspections)
		lastInspectionDate = try container.decode(Date.self, forKey: .lastInspectionDate)
		location = try container.decode(Location.self, forKey: .location)
		name = try container.decode(String.self, forKey: .name)
		nextActionDateScheduled = try container.decode(
			Date.self,
			forKey: .nextActionDateScheduled
		)
		treatments = try container.decode([Treatment].self, forKey: .treatments)
		useType = try container.decode(String.self, forKey: .useType)
		waterOrigin = try container.decode(String.self, forKey: .waterOrigin)
		zone = try container.decode(String.self, forKey: .zone)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(access, forKey: .access)
		try container.encode(active, forKey: .active)
		try container.encode(comments, forKey: .comments)
		try container.encode(created, forKey: .created)
		try container.encode(description, forKey: .description)
		try container.encode(habitat, forKey: .habitat)
		try container.encode(id, forKey: .id)
		try container.encode(inspections, forKey: .inspections)
		try container.encode(lastInspectionDate, forKey: .lastInspectionDate)
		try container.encode(location, forKey: .location)
		try container.encode(name, forKey: .name)
		try container.encode(nextActionDateScheduled, forKey: .nextActionDateScheduled)
		try container.encode(treatments, forKey: .treatments)
		try container.encode(useType, forKey: .useType)
		try container.encode(waterOrigin, forKey: .waterOrigin)
		try container.encode(zone, forKey: .zone)
	}
	static func == (lhs: MosquitoSource, rhs: MosquitoSource) -> Bool {
		return
			(lhs.access == rhs.access
			&& lhs.active == rhs.active
			&& lhs.comments == rhs.comments
			&& lhs.created == rhs.created
			&& lhs.description == rhs.description
			&& lhs.habitat == rhs.habitat
			&& lhs.inspections == rhs.inspections
			&& lhs.lastInspectionDate == rhs.lastInspectionDate
			&& lhs.location == rhs.location
			&& lhs.name == rhs.name
			&& lhs.nextActionDateScheduled == rhs.nextActionDateScheduled
			&& lhs.treatments == rhs.treatments
			&& lhs.useType == rhs.useType
			&& lhs.waterOrigin == rhs.waterOrigin
			&& lhs.zone == rhs.zone)
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(access)
		hasher.combine(active)
		hasher.combine(comments)
		hasher.combine(created)
		hasher.combine(description)
		hasher.combine(habitat)
		hasher.combine(inspections)
		hasher.combine(lastInspectionDate)
		hasher.combine(location)
		hasher.combine(name)
		hasher.combine(nextActionDateScheduled)
		hasher.combine(treatments)
		hasher.combine(useType)
		hasher.combine(waterOrigin)
		hasher.combine(zone)
	}
}

final class ServiceRequest: Codable, Identifiable, Note {
	enum CodingKeys: CodingKey {
		case address
		case assignedTechnician
		case city
		case created
		case hasDog
		case hasSpanishSpeaker
		case id
		case location
		case priority
		case source
		case status
		case target
		case zip
	}
	var address: String
	var assignedTechnician: String
	var city: String
	var created: Date
	var hasDog: Bool?
	var hasSpanishSpeaker: Bool?
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
		assignedTechnician: String,
		city: String,
		created: Date,
		hasDog: Bool?,
		hasSpanishSpeaker: Bool?,
		id: UUID,
		location: Location,
		priority: String,
		source: String,
		status: String,
		target: String,
		zip: String
	) {
		self.address = address
		self.assignedTechnician = assignedTechnician
		self.city = city
		self.created = created
		self.hasDog = hasDog
		self.hasSpanishSpeaker = hasSpanishSpeaker
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
		assignedTechnician = try container.decode(String.self, forKey: .assignedTechnician)
		city = try container.decode(String.self, forKey: .city)
		created = try container.decode(Date.self, forKey: .created)
		hasDog = try container.decode(Bool?.self, forKey: .hasDog)
		hasSpanishSpeaker = try container.decode(Bool?.self, forKey: .hasSpanishSpeaker)
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
		try container.encode(assignedTechnician, forKey: .assignedTechnician)
		try container.encode(city, forKey: .city)
		try container.encode(created, forKey: .created)
		try container.encode(hasDog, forKey: .hasDog)
		try container.encode(hasSpanishSpeaker, forKey: .hasSpanishSpeaker)
		try container.encode(id, forKey: .id)
		try container.encode(location, forKey: .location)
		try container.encode(priority, forKey: .priority)
		try container.encode(source, forKey: .source)
		try container.encode(status, forKey: .status)
		try container.encode(target, forKey: .target)
		try container.encode(zip, forKey: .zip)
	}
	static func == (lhs: ServiceRequest, rhs: ServiceRequest) -> Bool {
		return
			(lhs.address == rhs.address
			&& lhs.assignedTechnician == rhs.assignedTechnician
			&& lhs.city == rhs.city
			&& lhs.created == rhs.created
			&& lhs.hasDog == rhs.hasDog
			&& lhs.hasSpanishSpeaker == rhs.hasSpanishSpeaker
			&& lhs.location == rhs.location
			&& lhs.priority == rhs.priority
			&& lhs.source == rhs.source
			&& lhs.status == rhs.status
			&& lhs.target == rhs.target
			&& lhs.zip == rhs.zip)
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(address)
		hasher.combine(assignedTechnician)
		hasher.combine(city)
		hasher.combine(created)
		hasher.combine(hasDog)
		hasher.combine(hasSpanishSpeaker)
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

	init(
		created: Date,
		description: String,
		id: UUID,
		location: Location,
		name: String
	) {
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
		return
			(lhs.created == rhs.created
			&& lhs.description == rhs.description
			&& lhs.location == rhs.location
			&& lhs.name == rhs.name)
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
		case fieldTechnician
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
	var fieldTechnician: String
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
		fieldTechnician: String,
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
		self.fieldTechnician = fieldTechnician
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
		fieldTechnician = try container.decode(String.self, forKey: .fieldTechnician)
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
		try container.encode(fieldTechnician, forKey: .fieldTechnician)
		try container.encode(habitat, forKey: .habitat)
		try container.encode(product, forKey: .product)
		try container.encode(quantity, forKey: .quantity)
		try container.encode(quantityUnit, forKey: .quantityUnit)
		try container.encode(siteCondition, forKey: .siteCondition)
		try container.encode(treatAcres, forKey: .treatAcres)
		try container.encode(treatHectares, forKey: .treatHectares)
	}
	static func == (lhs: Treatment, rhs: Treatment) -> Bool {
		return
			(lhs.comments == rhs.comments
			&& lhs.created == rhs.created
			&& lhs.fieldTechnician == rhs.fieldTechnician
			&& lhs.habitat == rhs.habitat
			&& lhs.product == rhs.product
			&& lhs.quantity == rhs.quantity
			&& lhs.quantityUnit == rhs.quantityUnit
			&& lhs.siteCondition == rhs.siteCondition
			&& lhs.treatAcres == rhs.treatAcres
			&& lhs.treatHectares == rhs.treatHectares)
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(comments)
		hasher.combine(created)
		hasher.combine(fieldTechnician)
		hasher.combine(habitat)
		hasher.combine(product)
		hasher.combine(quantity)
		hasher.combine(quantityUnit)
		hasher.combine(siteCondition)
		hasher.combine(treatAcres)
		hasher.combine(treatHectares)
	}
}
