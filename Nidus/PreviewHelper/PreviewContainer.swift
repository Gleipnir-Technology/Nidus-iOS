//
//  PreviewContainer.swift
//  Nidus
//
//  Created by Eli Ribble on 3/17/25.
//

import Foundation
import SwiftData

struct Preview {

	let modelContainer: ModelContainer
	init() {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		do {
			modelContainer = try ModelContainer(for: Note.self, configurations: config)
		}
		catch {
			fatalError("Could not initialize ModelContainer")
		}
	}

	func addExamples(_ examples: [Note]) {
		Task { @MainActor in
			examples.forEach { example in modelContainer.mainContext.insert(example) }
		}
	}
}
