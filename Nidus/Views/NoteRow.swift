//
//  NoteRow.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//
import CoreLocation
import SwiftUI

struct NoteRow: View {
	var note: Note
	var userLocation: CLLocation?

	func distanceString() -> String {
		if let ul = userLocation {
			if let noteCoord = note.location {
				let noteLocation = CLLocation(
					latitude: noteCoord.latitude,
					longitude: noteCoord.longitude
				)
				let distance = noteLocation.distance(from: ul)
				return String(format: "%.1f m", distance)
			}
			else {
				return "No location recorded"
			}
		}
		else {
			return "Location unavailable"
		}
	}
	var body: some View {
		HStack {
			Label(note.category.name, systemImage: note.category.icon)
			Text(distanceString())
			Spacer()
		}
		.padding()
	}
}

#Preview("note 1") {
	Group {
		NoteRow(note: Note.dog)
	}
}
