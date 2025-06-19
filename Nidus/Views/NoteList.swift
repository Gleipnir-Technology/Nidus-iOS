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
	var currentLocation: CLLocation
	var notes: [AnyNote]

	var body: some View {
		if notes.count == 0 {
			Text("No notes")
		}
		else {
			NoteList(currentLocation: currentLocation, notes: notes)
		}
	}
}

struct NoteList: View {
	var currentLocation: CLLocation
	var notes: [AnyNote]

	var notesByDistance: [AnyNote] {
		var byDistance: [AnyNote] = notes
		byDistance.sort(by: { (an1: AnyNote, an2: AnyNote) -> Bool in
			return currentLocation.distance(
				from: CLLocation(
					latitude: an1.coordinate.latitude,
					longitude: an1.coordinate.longitude
				)
			)
				< currentLocation.distance(
					from: CLLocation(
						latitude: an2.coordinate.latitude,
						longitude: an2.coordinate.longitude
					)
				)
		})
		return byDistance
	}
	var body: some View {
		List(notesByDistance) { note in
			NavigationLink {
				switch note.category {
				case .mosquitoSource:
					MosquitoSourceDetail(source: note.asMosquitoSource()!)
				default:
					NoteEditor(currentLocation: currentLocation, note: note)
				}
			} label: {
				NoteRow(currentLocation: currentLocation, note: note)
			}
		}
	}
}
