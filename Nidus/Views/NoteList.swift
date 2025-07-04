//
//  NoteList.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//
import CoreLocation
import OSLog
import SwiftData
import SwiftUI

struct NoteListView: View {
	var currentLocation: CLLocation
	var locationDataManager: LocationDataManager
	var notes: [AnyNote]
	let onFilterAdded: (FilterInstance) -> Void
	var onNoteSave: ((NidusNote, Bool) throws -> Void)

	var body: some View {
		NavigationStack {
			if notes.count == 0 {
				Text("No notes")
			}
			else {
				NoteList(
					currentLocation: currentLocation,
					locationDataManager: locationDataManager,
					notes: notes,
					onFilterAdded: onFilterAdded,
					onNoteSave: onNoteSave
				).toolbar {
					Menu("Sorting") {
						Text("Sort by...")
						Button("Distance") {
							Logger.foreground.info("sort by distance")
						}
						Button("Tag") {
							Logger.foreground.info("sort by tag")
						}
					}

				}
			}
		}
	}
}

struct NoteList: View {
	var currentLocation: CLLocation
	var locationDataManager: LocationDataManager
	var notes: [AnyNote]
	let onFilterAdded: (FilterInstance) -> Void
	var onNoteSave: ((NidusNote, Bool) throws -> Void)

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
					MosquitoSourceDetail(
						onFilterAdded: onFilterAdded,
						source: note.asMosquitoSource()!
					)
				case .nidus:
					EditNidusNoteView(
						locationDataManager: locationDataManager,
						note: note.asNidusNote()!,
						onSave: onNoteSave
					)
				case .serviceRequest:
					ServiceRequestDetail(
						onFilterAdded: onFilterAdded,
						request: note.asServiceRequest()!
					)
				case .trapData:
					TrapDataDetail(
						onFilterAdded: onFilterAdded,
						trapData: note.asTrapData()!
					)
				default:
					NoteEditor(currentLocation: currentLocation, note: note)
				}
			} label: {
				NoteRow(currentLocation: currentLocation, note: note)
			}
		}
	}
}

struct NoteList_Previews: PreviewProvider {
	static var onFilterAdded: (FilterInstance) -> Void {
		{ _ in }
	}
	static var onNoteSave: (NidusNote, Bool) throws -> Void {
		{ _, _ in }
	}
	static var previews: some View {
		NoteListView(
			currentLocation: CLLocation.visaliaCenter,
			locationDataManager: LocationDataManagerFake(),
			notes: [],
			onFilterAdded: onFilterAdded,
			onNoteSave: onNoteSave
		).previewDisplayName("empty")
		NoteListView(
			currentLocation: CLLocation.visaliaCenter,
			locationDataManager: LocationDataManagerFake(),
			notes: AnyNote.previewListShort,
			onFilterAdded: onFilterAdded,
			onNoteSave: onNoteSave
		).previewDisplayName("populated")
	}
}
