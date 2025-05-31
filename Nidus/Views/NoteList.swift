//
//  NoteList.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//
import CoreLocation
import SwiftData
import SwiftUI

struct NoteListView: View {
	@Environment(\.modelContext) private var modelContext
	var notes: [AnyNote]
	var userLocation: CLLocation?

	var body: some View {
		if notes.count == 0 {
			Text("No notes yet")
		}
		else {
			NoteList(notes: notes, userLocation: userLocation)
		}
	}
}

struct NoteList: View {
	@Environment(\.modelContext) private var modelContext
	var notes: [AnyNote]
	var userLocation: CLLocation?

	var body: some View {
		List(notes) { note in
			NavigationLink {
				NoteEditor(note: note, userLocation: userLocation)
			} label: {
				NoteRow(note: note, userLocation: userLocation)
			}
		}
	}
}
