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
	@Binding var filterInstances: [String: FilterInstance]
	@State private var showingAddFilter = false
	let notesCountFiltered: Int
	let notesCountTotal: Int

	var onFilterChange: (() -> Void)

	func onFilterAdd(_ filter: FilterInstance) {
		onFilterChange()
	}

	func onFilterRemove() {
		onFilterChange()
	}

	private var notesFilteredPercentageDisplay: String {
		String(format: "%.1f%%", Double(notesCountFiltered) / Double(notesCountTotal) * 100)
	}

	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				// Header
				headerView

				// Active Filters List
				if filterInstances.isEmpty {
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
					filterInstances: $filterInstances,
					onFilterAdd: onFilterAdd
				)
			}
		}
	}

	private func filtersByName() -> [FilterInstance] {
		let sortedArray = filterInstances.sorted(by: { $0.key < $1.key }).map { $0.value }
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

				if !filterInstances.isEmpty {
					Button("Clear All") {
						filterInstances.removeAll()
						onFilterRemove()
					}
					.font(.subheadline)
					.foregroundColor(.red)
				}
			}

			Text(
				"\(filterInstances.count) filter\(filterInstances.count == 1 ? "" : "s") applied"
			)
			.font(.caption)
			.foregroundColor(.secondary)
			if notesCountTotal == 0 {
				Text("No notes yet to be filtered").font(.caption).foregroundColor(
					.secondary
				)
			}
			else {
				Text(
					"\(notesCountFiltered)/\(notesCountTotal) notes filtered (\(notesFilteredPercentageDisplay))"
				).font(.caption)
					.foregroundColor(.secondary)
			}
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
				ForEach(filtersByName()) { filterInstance in
					FilterRowView(filter: filterInstance) {
						removeFilter(filterInstance)
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
	private func removeFilter(_ filter: FilterInstance) {
		withAnimation(.easeInOut(duration: 0.3)) {
			self.filterInstances.removeValue(forKey: filter.Name())
			onFilterRemove()
		}
	}
}

// MARK: - Filter Row View
struct FilterRowView: View {
	let filter: FilterInstance
	let onRemove: () -> Void

	var body: some View {
		HStack(spacing: 12) {
			// Filter Icon
			Circle()
				.fill(Color.blue.opacity(0.1))
				.frame(width: 40, height: 40)
				.overlay(
					Image(systemName: filter.filter.IconName())
						.foregroundColor(.blue)
						.font(.system(size: 18))
				)

			// Filter Details
			VStack(alignment: .leading, spacing: 4) {
				Text(filter.Name())
					.font(.headline)
					.foregroundColor(.primary)

				HStack {
					Text("Value:")
						.font(.caption)
						.foregroundColor(.secondary)

					Text(filter.value)
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
}

// MARK: - Add Filter Sheet
struct AddFilterSheet: View {
	@Binding var filterInstances: [String: FilterInstance]
	@Environment(\.dismiss) private var dismiss
	@State private var selectedFilterName: String = filters.category.Name()
	@State private var stringValue: String = ""
	@State private var boolValue: Bool = false
	var onFilterAdd: (FilterInstance) -> Void

	private var availableFilterNames: [String] {
		filters.all.filter { filter in
			!filterInstances.contains { $0.value.filter.Name() == filter.Name() }
		}.map { $0.Name() }
	}
	private var filterExhaustedSection: some View {
		Section {
			if availableFilterNames.isEmpty {
				Text("All available filters have been added")
					.foregroundColor(.secondary)
					.font(.body)
			}
			else {
				EmptyView()
			}
		}
	}
	private var filterTypeSection: some View {
		Section("Filter Type") {
			Picker("Select Filter", selection: $selectedFilterName) {
				ForEach(availableFilterNames, id: \.self) {
					filterName in
					Text(filterName)
						.tag(filterName)
				}
			}
			.pickerStyle(.menu)
		}

	}
	private var filterValueSection: some View {
		Section("Filter Value") {
			if selectedFilter as? FilterBool != nil {
				Toggle(isOn: $boolValue) {
					Text(selectedFilterName)
				}
			}
			else if selectedFilter as? FilterChoice != nil {
				Picker("Select Value", selection: $stringValue) {
					ForEach(
						(selectedFilter as? FilterChoice)!.choices,
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
					"Enter \(selectedFilterName)",
					text: $stringValue
				)
				.textFieldStyle(.roundedBorder)
			}
		}
	}

	private var selectedFilter: any Filter {
		for filter in filters.all {
			if filter.Name() == selectedFilterName {
				return filter
			}
		}
		fatalError("No filter named \(selectedFilterName)")
	}

	var body: some View {
		NavigationView {
			Form {
				filterTypeSection
				filterValueSection
				filterExhaustedSection
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
				if let firstAvailable = availableFilterNames.first {
					selectedFilterName = firstAvailable
					// Reset values when filter type changes
					stringValue =
						(selectedFilter as? FilterChoice != nil)
						? ((selectedFilter as? FilterChoice)!.choices.first
							?? "")
						: ""
					boolValue = false
				}
			}
			.onChange(of: selectedFilterName) { _, newValue in
				// Reset values when filter type changes
				stringValue =
					(selectedFilter as? FilterChoice != nil)
					? ((selectedFilter as? FilterChoice)!.choices.first ?? "")
					: ""
				boolValue = false
			}
		}
	}

	private var canAddFilter: Bool {
		if availableFilterNames.isEmpty {
			return false
		}

		if selectedFilter as? FilterBool != nil {
			return true
		}
		else if selectedFilter as? FilterChoice != nil {
			return !stringValue.isEmpty
		}
		else {
			return !stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
	}

	private func addFilter() {
		var value: String
		if selectedFilter as? FilterBool != nil {
			value = String(boolValue)
		}
		else if selectedFilter as? FilterChoice != nil {
			value = stringValue
		}
		else {
			value = stringValue.trimmingCharacters(
				in: .whitespacesAndNewlines
			)
		}
		let newFilter = FilterInstance(selectedFilter, value)

		withAnimation(.easeInOut(duration: 0.3)) {
			filterInstances[selectedFilterName] = newFilter
			onFilterAdd(newFilter)
		}

		dismiss()
	}
}

// MARK: - Preview
struct FilterView_Previews: PreviewProvider {
	@State static var filterInstances: [String: FilterInstance] = [:]
	static var previews: some View {
		FilterView(
			filterInstances: $filterInstances,
			notesCountFiltered: 123,
			notesCountTotal: 250
		) {}
	}
}

struct FilterViewNoNotes_Previews: PreviewProvider {
	@State static var filterInstances: [String: FilterInstance] = [:]
	static var previews: some View {
		FilterView(
			filterInstances: $filterInstances,
			notesCountFiltered: 0,
			notesCountTotal: 0
		) {}
	}
}
