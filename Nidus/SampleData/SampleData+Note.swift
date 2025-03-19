//
//  SampleData+Note.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//
import Foundation

extension Note {
	static let advise = Note(
		category: NoteCategory.todo,
		content: "Make sure to let the Bob know we arrived.",
		location: NoteLocation(latitude: 33.3024121, longitude: -111.7349332)
	)
	static let wave = Note(
		category: NoteCategory.entry,
		content: "Wave at the nice guard.",
		location: NoteLocation(latitude: 33.3060406, longitude: -111.7342217)
	)
	static let dog = Note(
		category: NoteCategory.info,
		content: "There's a dog here.\nIt's annoying.",
		location: NoteLocation(latitude: 33.3026129, longitude: -111.7328528)
	)
}
