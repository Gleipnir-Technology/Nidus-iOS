//
//  SampleData+NoteType.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//

import Foundation
import SwiftData

extension NoteCategory {
	static let entry = NoteCategory(color: .green, icon: "lock.circle", name: "entry")
	static let info = NoteCategory(color: .blue, icon: "info.circle", name: "info")
	static let todo = NoteCategory(color: .red, icon: "checkmark.circle", name: "todo")

	static func insertSampleData(modelContext: ModelContext) {
		modelContext.insert(entry)
		modelContext.insert(info)
		modelContext.insert(todo)

		modelContext.insert(Note.advise)
		modelContext.insert(Note.standingWater)
		modelContext.insert(Note.pondTreatment)
		modelContext.insert(Note.gardenPonds)
		modelContext.insert(Note.denseBushes)
		modelContext.insert(Note.brokenGutter)
		modelContext.insert(Note.trashCans)
		modelContext.insert(Note.poolEquipment)
		modelContext.insert(Note.constructionSite)
		modelContext.insert(Note.overgrownArea)
		modelContext.insert(Note.roadSideDitch)
		modelContext.insert(Note.abandonedSwimmingPool)
		modelContext.insert(Note.birdbath)
		modelContext.insert(Note.compostPile)
		modelContext.insert(Note.garageClutter)
		modelContext.insert(Note.irrigationSystem)
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
