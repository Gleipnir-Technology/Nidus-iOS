//
//  Filter.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/19/25.
//
import SwiftUI

struct FilterGlobal {
	let actionTaken = FilterString("Action Taken", "figure") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		for inspection in source.inspections {
			if inspection.actionTaken == nil {
				return value == "Unknown"
			}
			else if inspection.actionTaken! == value {
				return true
			}
		}
		return false
	}
	let assignedTechnician = FilterString("Assigned Technician", "figure.wave") { note, value in
		guard let sr = note.asServiceRequest() else { return false }
		return sr.assignedTechnician == value
	}
	let category = FilterChoice(
		"Category",
		[
			NoteCategory.mosquitoSource.name, NoteCategory.serviceRequest.name,
			NoteCategory.trapData.name,
		],
		"heart.text.clipboard"
	) { note, value in
		return note.category.name == value
	}
	let fieldTechnician = FilterString("Field Technician", "figure,wave") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		for inspection in source.inspections {
			if inspection.fieldTechnician == value {
				return true
			}
		}
		return false
	}
	let habitat = FilterString("Habitat", "globe.americas.fill") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		return source.habitat == value
	}
	let hasDog = FilterBool("Has Dog", "dog") { note, value in
		guard let sr = note.asServiceRequest() else { return false }
		return sr.hasDog == value
	}
	let hasSpanishSpeaker = FilterBool("Has Spanish Speaker", "figure.socialdance") {
		note,
		value in
		guard let sr = note.asServiceRequest() else { return false }
		return sr.hasSpanishSpeaker != nil && sr.hasSpanishSpeaker! == value
	}
	let isActive = FilterBool("Is Active", "checkmark.circle") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		return source.active == value
	}
	let locationName = FilterString("Location Name", "map") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		for inspection in source.inspections {
			if inspection.locationName == nil {
				return value == "Unknown"
			}
			else if inspection.locationName == value {
				return true
			}
		}
		return false
	}
	let priority = FilterString("Priority", "list.number") { note, value in
		guard let sr = note.asServiceRequest() else { return false }
		return sr.priority == value
	}
	let product = FilterString("Product", "gyroscope") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		for treatment in source.treatments {
			if treatment.product == value {
				return true
			}
		}
		return false
	}
	let siteCondition = FilterString("Site Condition", "toilet") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		for inspection in source.inspections {
			if inspection.siteCondition == nil {
				return value == "Unknown"
			}
			else if inspection.siteCondition == value {
				return true
			}
		}
		return false
	}
	let source = FilterString("Source", "globe.central.south.asia") { note, value in
		guard let sr = note.asServiceRequest() else { return false }
		return sr.source == value
	}
	let status = FilterString("Status", "star.circle.fill") { note, value in
		guard let sr = note.asServiceRequest() else { return false }
		return sr.status == value
	}
	let target = FilterString("Target", "target") { note, value in
		guard let sr = note.asServiceRequest() else { return false }
		return sr.target == value
	}
	let useType = FilterString("Use Type", "house.lodge") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		return source.useType == value
	}
	let waterOrigin = FilterString("Water Origin", "drop.fill") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		return source.waterOrigin == value
	}
	let zone = FilterString("Zone", "bookmark.fill") { note, value in
		guard let source = note.asMosquitoSource() else { return false }
		return source.zone == value
	}
	let all: [any Filter]

	init() {
		self.all = [
			actionTaken,
			assignedTechnician,
			category,
			fieldTechnician,
			habitat,
			hasDog,
			hasSpanishSpeaker,
			isActive,
			priority,
			product,
			siteCondition,
			source,
			status,
			target,
			useType,
			waterOrigin,
			zone,
		]
	}

	func byName(_ name: String) -> (any Filter)? {
		return self.all.first { $0.Name() == name }
	}
}

let filters: FilterGlobal = FilterGlobal()

protocol Filter: Equatable, Hashable, Identifiable {
	func AllowsNote(_ note: AnyNote, _ value: String) -> Bool
	func IconName() -> String
	func Instance(_ value: String) -> FilterInstance
	func Name() -> String
}

class FilterBool: Equatable, Filter, Hashable {
	let filterFunction: (AnyNote, Bool?) -> Bool
	let iconName: String
	let name: String

	init(
		_ name: String,
		_ iconName: String,
		_ filterFunction: @escaping (AnyNote, Bool?) -> Bool
	) {
		self.filterFunction = filterFunction
		self.iconName = iconName
		self.name = name
	}
	func AllowsNote(_ note: AnyNote, _ value: String) -> Bool {
		let boolValue: Bool = value == String(true)
		return filterFunction(note, boolValue)
	}
	func IconName() -> String {
		return iconName
	}
	func Instance(_ value: String) -> FilterInstance {
		return FilterInstance(self, value)
	}
	func Name() -> String {
		return name
	}
	static func == (lhs: FilterBool, rhs: FilterBool) -> Bool {
		return lhs.name == rhs.name
	}
	static func == (lhs: FilterBool, rhs: any Filter) -> Bool {
		return lhs.Name() == rhs.Name()
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}

class FilterString: Equatable, Filter, Hashable {
	let filterFunction: (AnyNote, String) -> Bool
	let iconName: String
	let name: String

	init(
		_ name: String,
		_ iconName: String,
		_ filterFunction: @escaping (AnyNote, String) -> Bool
	) {
		self.filterFunction = filterFunction
		self.iconName = iconName
		self.name = name
	}
	func AllowsNote(_ note: AnyNote, _ value: String) -> Bool {
		return filterFunction(note, value)
	}
	func IconName() -> String {
		return iconName
	}
	func Instance(_ value: String) -> FilterInstance {
		return FilterInstance(self, value)
	}
	func Name() -> String {
		return name
	}
	static func == (lhs: FilterString, rhs: FilterString) -> Bool {
		return lhs.name == rhs.name
	}
	static func == (lhs: FilterString, rhs: any Filter) -> Bool {
		return lhs.Name() == rhs.Name()
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}

class FilterChoice: Equatable, Filter, Hashable {
	let choices: [String]
	let filterFunction: (AnyNote, String) -> Bool
	let iconName: String
	let name: String

	init(
		_ name: String,
		_ choices: [String],
		_ iconName: String,
		_ filterFunction: @escaping (AnyNote, String) -> Bool
	) {
		self.choices = choices
		self.filterFunction = filterFunction
		self.iconName = iconName
		self.name = name
	}
	func AllowsNote(_ note: AnyNote, _ value: String) -> Bool {
		return filterFunction(note, value)
	}
	func IconName() -> String {
		return iconName
	}
	func Instance(_ value: String) -> FilterInstance {
		return FilterInstance(self, value)
	}
	func Name() -> String {
		return name
	}
	static func == (lhs: FilterChoice, rhs: FilterChoice) -> Bool {
		return lhs.name == rhs.name
	}
	static func == (lhs: FilterChoice, rhs: any Filter) -> Bool {
		return lhs.Name() == rhs.Name()
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}

class FilterInstance: Hashable, Identifiable {
	let filter: any Filter
	let value: String

	init(_ filter: any Filter, _ value: String) {
		self.filter = filter
		self.value = value
	}

	func AllowsNote(_ note: AnyNote) -> Bool {
		return filter.AllowsNote(note, value)
	}
	func Name() -> String {
		return filter.Name()
	}
	static func fromString(_ input: String) -> FilterInstance? {
		let components = input.split(separator: "=")
		guard components.count == 2 else { return nil }
		guard let filter = filters.byName(String(components[0])) else {
			return nil
		}
		let val = components[1]
		return filter.Instance(String(val))
	}

	func toString() -> String {
		return "\(filter.Name())=\(value)"
	}
	static func == (lhs: FilterInstance, rhs: FilterInstance) -> Bool {
		return lhs.filter.Name() == rhs.filter.Name() && lhs.value == rhs.value
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(filter)
		hasher.combine(value)
	}
}
