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
	var currentLocation: CLLocation?
	var notes: [AnyNote]

	var body: some View {
		if notes.count == 0 {
			Text("No notes yet. Try going to settings to set up sync.")
		}
		else {
			NoteList(currentLocation: currentLocation, notes: notes)
		}
	}
}

struct NoteList: View {
	var currentLocation: CLLocation?
	var notes: [AnyNote]

	var body: some View {
		List(notes) { note in
			NavigationLink {
				NoteEditor(currentLocation: currentLocation, note: note)
			} label: {
				NoteRow(currentLocation: currentLocation, note: note)
			}
		}
	}
}
