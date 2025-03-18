//
//  NoteCategorySelector.swift
//  Nidus
//
//  Created by Eli Ribble on 3/18/25.
//
import SwiftData
import SwiftUI

struct CategorySelectorView: View {
	@Binding var selectedCategory: NoteCategory?
	@Environment(\.modelContext) private var modelContext

	@State private var newCategoryName: String = ""
	@State private var isAddingNewCategory: Bool = false

	@Query(sort: \NoteCategory.name) private var categories: [NoteCategory]

	var body: some View {
		List {
			// Existing categories
			ForEach(categories) { category in
				CategoryRow(
					category: category,
					isSelected: selectedCategory?.id == category.id
				)
				.onTapGesture {
					selectedCategory = category
				}
			}

			// Add new category button
			Button(action: {
				isAddingNewCategory = true
			}) {
				HStack {
					Image(systemName: "plus.circle.fill")
						.foregroundColor(.blue)
					Text("Add New Category")
				}
			}
		}
		.sheet(isPresented: $isAddingNewCategory) {
			NavigationView {
				AddCategoryView(
					newCategoryName: $newCategoryName,
					isPresented: $isAddingNewCategory,
					selectedCategory: $selectedCategory
				)
			}
		}
	}
}

struct CategoryRow: View {
	let category: NoteCategory
	let isSelected: Bool

	var body: some View {
		HStack {
			Text(category.name)
			Spacer()
			if isSelected {
				Image(systemName: "checkmark")
					.foregroundColor(.blue)
			}
		}
	}
}

struct AddCategoryView: View {
	@Environment(\.modelContext) private var modelContext
	@Binding var newCategoryName: String
	@Binding var isPresented: Bool
	@Binding var selectedCategory: NoteCategory?

	var body: some View {
		Form {
			Section {
				TextField("Category Name", text: $newCategoryName)
			}
		}
		.navigationTitle("New Category")
		.navigationBarItems(
			leading: Button("Cancel") {
				newCategoryName = ""
				isPresented = false
			},
			trailing: Button("Add") {
				let trimmedName = newCategoryName.trimmingCharacters(
					in: .whitespacesAndNewlines
				)
				guard !trimmedName.isEmpty else { return }
				// guard !modelContext.categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else { return }
				let newCategory = NoteCategory(name: trimmedName)
				modelContext.insert(newCategory)
				selectedCategory = newCategory
				newCategoryName = ""
				isPresented = false
			}
			.disabled(
				newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
					.isEmpty
			)
		)
	}
}

struct NoteCategorySelector_Previews: PreviewProvider {
	@State static var selectedCategory: NoteCategory? = nil
	static var previews: some View {
		ModelContainerPreview(ModelContainer.sample) {
			CategorySelectorView(selectedCategory: $selectedCategory)
		}
	}
}
