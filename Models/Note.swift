//
//  Task.swift
//  Nidus
//
//  Created by Eli Ribble on 3/10/25.
//
import SwiftData

@Model
final class NoteCategory {
	@Attribute(.unique) var name: String
	@Relationship(deleteRule: .cascade, inverse: \Note.category)
	var notes = [Note]()

	init(name: String) {
		self.name = name
	}
}

@Model
final class Note {
	var title: String
	var category: NoteCategory

	init(title: String, category: NoteCategory) {
		self.title = title
		self.category = category
	}

}
