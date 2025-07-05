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
	var isTextFieldFocused: FocusState<Bool>.Binding
	var locationDataManager: LocationDataManager
	var notes: [AnyNote]
	@Binding var noteBuffer: ModelNoteBuffer
	let onFilterAdded: (FilterInstance) -> Void

	var body: some View {
		NavigationView {
			if notes.count == 0 {
				Text("No notes")
			}
			else {
				NoteList(
					currentLocation: currentLocation,
					isTextFieldFocused: isTextFieldFocused,
					locationDataManager: locationDataManager,
					notes: notes,
					noteBuffer: $noteBuffer,
					onFilterAdded: onFilterAdded
				)
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Notes")
				.toolbar {
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
	var isTextFieldFocused: FocusState<Bool>.Binding
	var locationDataManager: LocationDataManager
	var notes: [AnyNote]
	@Binding var noteBuffer: ModelNoteBuffer
	let onFilterAdded: (FilterInstance) -> Void

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
						isTextFieldFocused: isTextFieldFocused,
						locationDataManager: locationDataManager,
						note: note.asNidusNote()!,
						noteBuffer: $noteBuffer
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
	@FocusState static var isTextFieldFocused: Bool
	@State static var noteBuffer: ModelNoteBuffer = ModelNoteBuffer()
	static var onFilterAdded: (FilterInstance) -> Void {
		{ _ in }
	}
	static var previews: some View {
		NoteListView(
			currentLocation: CLLocation.visaliaCenter,
			isTextFieldFocused: $isTextFieldFocused,
			locationDataManager: LocationDataManagerFake(),
			notes: [],
			noteBuffer: $noteBuffer,
			onFilterAdded: onFilterAdded
		).previewDisplayName("empty")
		NoteListView(
			currentLocation: CLLocation.visaliaCenter,
			isTextFieldFocused: $isTextFieldFocused,
			locationDataManager: LocationDataManagerFake(),
			notes: AnyNote.previewListShort,
			noteBuffer: $noteBuffer,
			onFilterAdded: onFilterAdded
		).previewDisplayName("populated")
	}
}
