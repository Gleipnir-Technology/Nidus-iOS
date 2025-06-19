//
//  Filter.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/19/25.
//
import SwiftUI

enum FilterType: String, CaseIterable {
	case age = "Age"
	case description = "Description"
	case name = "Name"
	case type = "Type"
	case hasComments = "Has Comments"
	case hasRatings = "Has Ratings"

	var isBooleanFilter: Bool {
		switch self {
		case .hasComments, .hasRatings:
			return true
		case .age, .description, .name, .type:
			return false
		}
	}

	var isSelectionFilter: Bool {
		switch self {
		case .type:
			return true
		case .age, .description, .name, .hasComments, .hasRatings:
			return false
		}
	}

	var selectionOptions: [String] {
		switch self {
		case .type:
			return NoteCategory.all.map(\.name)
		default:
			return []
		}
	}
}

struct Filter: Identifiable, Equatable, Hashable {
	let id = UUID()
	let type: FilterType
	private let _boolValue: Bool
	private let _stringValue: String

	init(type: FilterType, value: String) {
		self.type = type
		switch type {
		case .age, .description, .name:
			_boolValue = false
			_stringValue = value
		case .type:
			_boolValue = false
			_stringValue = value
		case .hasComments, .hasRatings:
			_boolValue = value == String(true)
			_stringValue = String(true)
		}
	}
	var displayValue: String {
		type.isBooleanFilter ? (_boolValue ? "Yes" : "No") : _stringValue
	}

	var stringValue: String {
		if type.isBooleanFilter {
			return String(_boolValue)
		}
		else {
			return _stringValue
		}
	}

	static func fromString(_ input: String) -> Filter? {
		let components = input.split(separator: "=")
		guard components.count == 2 else { return nil }
		let filterTypeString = components[0]
		guard let filterType = FilterType(rawValue: String(filterTypeString)) else {
			return nil
		}
		let val = components[1]
		return Filter(type: filterType, value: String(val))
	}

	func toString() -> String {
		return "\(type.rawValue)=\(stringValue)"
	}
}
