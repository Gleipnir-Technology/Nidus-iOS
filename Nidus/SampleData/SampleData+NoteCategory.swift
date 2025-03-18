//
//  SampleData+NoteType.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//

import Foundation
import SwiftData

extension NoteCategory {
	static let entry = NoteCategory(name: "entry")
	static let info = NoteCategory(name: "info")
	static let todo = NoteCategory(name: "todo")

	static func insertSampleData(modelContext: ModelContext) {
		modelContext.insert(entry)
		modelContext.insert(info)
		modelContext.insert(todo)

		modelContext.insert(Note.gate)
		modelContext.insert(Note.station)
		modelContext.insert(Note.trap)
	}

	static func reloadSampleData(modelContext: ModelContext) {
		do {
			try modelContext.delete(model: NoteCategory.self)
			insertSampleData(modelContext: modelContext)
		}
		catch {
			fatalError(error.localizedDescription)
		}
	}
}
