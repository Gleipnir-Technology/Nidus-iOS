//
//  SampleData+NoteType.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//

import Foundation
import SwiftData

extension NoteCategory {
	static let entry = NoteCategory(icon: "lock.circle", name: "entry")
	static let info = NoteCategory(icon: "info.circle", name: "info")
	static let todo = NoteCategory(icon: "checkmark.circle", name: "todo")

	static func insertSampleData(modelContext: ModelContext) {
		modelContext.insert(entry)
		modelContext.insert(info)
		modelContext.insert(todo)

		modelContext.insert(Note.advise)
		modelContext.insert(Note.dog)
		modelContext.insert(Note.wave)
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
