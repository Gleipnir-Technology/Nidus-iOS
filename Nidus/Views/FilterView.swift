//
//  FilterView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/19/25.
//

import OSLog
import SwiftUI

// MARK: - Main Filter View
struct FilterView: View {
	@Binding var filters: Set<Filter>
	@State private var showingAddFilter = false
	var onFilterChange: ((Set<Filter>) -> Void)

	func onFilterAdd(_ filter: Filter) {
		let filters = Set(filters)
		onFilterChange(filters)
	}

	func onFilterRemove() {
		let filters = Set(filters)
		onFilterChange(filters)
	}

	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				// Header
				headerView

				// Active Filters List
				if filters.isEmpty {
					emptyStateView
				}
				else {
					activeFiltersView
				}

				Spacer()

				// Add Filter Button
				addFilterButton
			}
			.navigationTitle("Filters")
			.navigationBarTitleDisplayMode(.large)
			.sheet(isPresented: $showingAddFilter) {
				AddFilterSheet(
					filters: $filters,
					onFilterAdd: onFilterAdd
				)
			}
		}
	}

	private func filtersByName() -> [Filter] {
		let sortedArray = filters.sorted { $0.type.rawValue < $1.type.rawValue }
		return sortedArray
	}
	// MARK: - Header View
	private var headerView: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text("Active Filters")
					.font(.headline)
					.foregroundColor(.primary)

				Spacer()

				if !filters.isEmpty {
					Button("Clear All") {
						filters.removeAll()
						onFilterRemove()
					}
					.font(.subheadline)
					.foregroundColor(.red)
				}
			}

			Text(
				"\(filters.count) filter\(filters.count == 1 ? "" : "s") applied"
			)
			.font(.caption)
			.foregroundColor(.secondary)
		}
		.padding(.horizontal)
		.padding(.top, 8)
		.padding(.bottom, 16)
		.background(Color(.systemBackground))
	}

	// MARK: - Empty State
	private var emptyStateView: some View {
		VStack(spacing: 16) {
			Image(systemName: "line.3.horizontal.decrease.circle")
				.font(.system(size: 60))
				.foregroundColor(.secondary)

			Text("No Filters Applied")
				.font(.title2)
				.fontWeight(.medium)
				.foregroundColor(.primary)

			Text("Add filters to refine your data")
				.font(.body)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	// MARK: - Active Filters List
	private var activeFiltersView: some View {
		ScrollView {
			LazyVStack(spacing: 12) {
				ForEach(filtersByName()) { filter in
					FilterRowView(filter: filter) {
						removeFilter(filter)
					}
				}
			}
			.padding(.horizontal)
		}
	}

	// MARK: - Add Filter Button
	private var addFilterButton: some View {
		Button(action: {
			showingAddFilter = true
		}) {
			HStack {
				Image(systemName: "plus.circle.fill")
					.font(.title2)
				Text("Add Filter")
					.font(.headline)
			}
			.foregroundColor(.white)
			.frame(maxWidth: .infinity)
			.padding()
			.background(Color.blue)
			.cornerRadius(12)
		}
		.padding(.horizontal)
		.padding(.bottom, 34)  // Safe area padding
	}

	// MARK: - Helper Methods
	private func removeFilter(_ filter: Filter) {
		withAnimation(.easeInOut(duration: 0.3)) {
			filters.remove(at: filters.firstIndex(of: filter)!)
			onFilterRemove()
		}
	}
}

// MARK: - Filter Row View
struct FilterRowView: View {
	let filter: Filter
	let onRemove: () -> Void

	var body: some View {
		HStack(spacing: 12) {
			// Filter Icon
			Circle()
				.fill(Color.blue.opacity(0.1))
				.frame(width: 40, height: 40)
				.overlay(
					Image(systemName: iconForFilterType(filter.type))
						.foregroundColor(.blue)
						.font(.system(size: 18))
				)

			// Filter Details
			VStack(alignment: .leading, spacing: 4) {
				Text(filter.type.rawValue)
					.font(.headline)
					.foregroundColor(.primary)

				HStack {
					Text("Value:")
						.font(.caption)
						.foregroundColor(.secondary)

					Text(filter.displayValue)
						.font(.subheadline)
						.fontWeight(.medium)
						.foregroundColor(.primary)
						.padding(.horizontal, 8)
						.padding(.vertical, 2)
						.background(Color(.systemGray6))
						.cornerRadius(6)
				}
			}

			Spacer()

			// Remove Button
			Button(action: onRemove) {
				Image(systemName: "xmark.circle.fill")
					.foregroundColor(.red)
					.font(.title2)
			}
		}
		.padding()
		.background(Color(.systemBackground))
		.cornerRadius(12)
		.shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
	}

	private func iconForFilterType(_ type: FilterType) -> String {
		switch type {
		case .age:
			return "calendar"
		case .description:
			return "text.alignleft"
		case .hasComments:
			return "bubble.left"
		case .hasRatings:
			return "star"
		case .name:
			return "person"
		case .type:
			return "ant.circle"
		}
	}
}

// MARK: - Add Filter Sheet
struct AddFilterSheet: View {
	@Binding var filters: Set<Filter>
	@Environment(\.dismiss) private var dismiss
	@State private var selectedFilterType: FilterType = .age
	@State private var stringValue: String = ""
	@State private var boolValue: Bool = false
	var onFilterAdd: (Filter) -> Void

	private var availableFilterTypes: [FilterType] {
		FilterType.allCases.filter { filterType in
			!filters.contains { $0.type == filterType }
		}
	}

	var body: some View {
		NavigationView {
			Form {
				Section("Filter Type") {
					Picker("Select Filter", selection: $selectedFilterType) {
						ForEach(availableFilterTypes, id: \.self) {
							filterType in
							Text(filterType.rawValue)
								.tag(filterType)
						}
					}
					.pickerStyle(.menu)
				}

				Section("Filter Value") {
					if selectedFilterType.isBooleanFilter {
						Toggle(isOn: $boolValue) {
							Text(selectedFilterType.rawValue)
						}
					}
					else if selectedFilterType.isSelectionFilter {
						Picker("Select Value", selection: $stringValue) {
							ForEach(
								selectedFilterType.selectionOptions,
								id: \.self
							) { option in
								Text(option)
									.tag(option)
							}
						}
						.pickerStyle(.menu)
					}
					else {
						TextField(
							"Enter \(selectedFilterType.rawValue.lowercased())",
							text: $stringValue
						)
						.textFieldStyle(.roundedBorder)
					}
				}

				if availableFilterTypes.isEmpty {
					Section {
						Text("All available filters have been added")
							.foregroundColor(.secondary)
							.font(.body)
					}
				}
			}
			.navigationTitle("Add Filter")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Cancel") {
						dismiss()
					}
				}

				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Add") {
						addFilter()
					}
					.disabled(!canAddFilter)
				}
			}
			.onAppear {
				// Set the selected filter type to the first available option
				if let firstAvailable = availableFilterTypes.first {
					selectedFilterType = firstAvailable
					// Reset values when filter type changes
					stringValue =
						selectedFilterType.isSelectionFilter
						? (selectedFilterType.selectionOptions.first ?? "")
						: ""
					boolValue = false
				}
			}
			.onChange(of: selectedFilterType) { _, newValue in
				// Reset values when filter type changes
				stringValue =
					newValue.isSelectionFilter
					? (newValue.selectionOptions.first ?? "") : ""
				boolValue = false
			}
		}
	}

	private var canAddFilter: Bool {
		if availableFilterTypes.isEmpty {
			return false
		}

		if selectedFilterType.isBooleanFilter {
			return true
		}
		else if selectedFilterType.isSelectionFilter {
			return !stringValue.isEmpty
		}
		else {
			return !stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
	}

	private func addFilter() {
		var value: String
		if selectedFilterType.isBooleanFilter {
			value = String(boolValue)
		}
		else if selectedFilterType.isSelectionFilter {
			value = stringValue
		}
		else {
			value = stringValue.trimmingCharacters(
				in: .whitespacesAndNewlines
			)
		}
		let newFilter = Filter(type: selectedFilterType, value: value)

		withAnimation(.easeInOut(duration: 0.3)) {
			filters.insert(newFilter)
			onFilterAdd(newFilter)
		}

		dismiss()
	}
}

// MARK: - Preview
struct FilterView_Previews: PreviewProvider {
	@State static var filters: Set<Filter> = []
	static var previews: some View {
		FilterView(filters: $filters, onFilterChange: ({ _ in }))
	}
}
