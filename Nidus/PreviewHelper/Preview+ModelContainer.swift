//
//  Preview+ModelContainer.swift
//  Nidus
//
//  Created by Eli Ribble on 3/17/25.
//

import SwiftData

extension ModelContainer {
	static var empty: () throws -> ModelContainer = {
		let schema = Schema([Note.self])
		let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: schema, configurations: [configuration])
		return container
	}
	static var sample: () throws -> ModelContainer = {
		let schema = Schema([Note.self])
		let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: schema, configurations: [configuration])
		Task { @MainActor in
			Note.insertSampleData(modelContext: container.mainContext)
		}
		return container
	}
}
