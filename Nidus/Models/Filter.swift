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
			return ["Mosquito Source", "Mosquito Trap", "Service Request"]
		default:
			return []
		}
	}
}

struct Filter: Identifiable, Equatable, Hashable {
	let id = UUID()
	let type: FilterType
	var stringValue: String = ""
	var boolValue: Bool = false

	var displayValue: String {
		type.isBooleanFilter ? (boolValue ? "Yes" : "No") : stringValue
	}
}
