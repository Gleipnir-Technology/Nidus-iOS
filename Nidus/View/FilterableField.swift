//
//  FilterableField.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/22/25.
//
import SwiftUI

struct FilterableField: View {
	let filter: any Filter
	let label: String
	let value: String

	let addFilter: (any Filter, String) -> Void

	var body: some View {
		HStack {
			Button("Add Filter", systemImage: "line.3.horizontal.decrease") {
				addFilter(filter, value)
			}.labelStyle(.iconOnly)
			Text("\(label): \(value)")
			Spacer()
		}
	}
}
