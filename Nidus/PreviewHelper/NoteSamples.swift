//
//  NoteSamples.swift
//  Nidus
//
//  Created by Eli Ribble on 3/17/25.
//
import Foundation

extension NoteCategory {
	static var sampleCategories: [NoteCategory] {
		[
			NoteCategory(name: "Info"),
			NoteCategory(name: "Entry"),
			NoteCategory(name: "Todo"),
		]
	}
}
extension Note {
	static var sampleNotes: [Note] {
		[
			Note(title: "Note 1", category: NoteCategory.sampleCategories[0]),
			Note(title: "Note 2", category: NoteCategory.sampleCategories[1]),
		]
	}
}
