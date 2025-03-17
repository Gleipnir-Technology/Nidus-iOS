//
//  SampleData+NoteType.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//

import Foundation
import SwiftData

extension NoteCategory {
	static let info = NoteCategory(name: "info")

	static func insertSampleData(modelContext: ModelContext) {
		modelContext.insert(info)
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
