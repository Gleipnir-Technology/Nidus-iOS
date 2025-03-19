//
//  NidusApp.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//
import SwiftData
import SwiftUI

@MainActor
let appContainer: ModelContainer = {
	do {
		let schema = Schema([Note.self, NoteCategory.self, NoteLocation.self])
		let container = try ModelContainer(for: schema)

		// Make sure the persistent store is empty. If it's not, return the non-empty container.
		var itemFetchDescriptor = FetchDescriptor<NoteCategory>()
		itemFetchDescriptor.fetchLimit = 1

		guard try container.mainContext.fetch(itemFetchDescriptor).count == 0 else {
			return container
		}

		// This code only runs if the store is empty.
		let categories = [
			NoteCategory(icon: "lock.circle", name: "entry"),
			NoteCategory(icon: "info.circle", name: "info"),
			NoteCategory(icon: "checkmark.circle", name: "todo"),
		]
		for category in categories {
			container.mainContext.insert(category)
		}
		return container
	}
	catch {
		fatalError("Failed to create container")
	}
}()

@main
@MainActor
struct NidusApp: App {
	@State private var modelData = ModelData()
	@State private var locationDataManager = LocationDataManager()
	var body: some Scene {
		WindowGroup {
			ContentView().environment(locationDataManager)
		}
		.modelContainer(appContainer)
	}
}
