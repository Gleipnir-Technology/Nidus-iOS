import H3
import MapKit
import OSLog
import SwiftUI

/*
 Controller for the set of notes we're working with
 */
@Observable
class NotesController {
	var store = NotesStore()

	func filterAdd(_ instance: FilterInstance) {
		store.filterInstances[instance.Name()] = instance
		onFilterChange()
	}

	func noteDelete() {
		Logger.foreground.warning("deleteNote not implemented")
	}

	func showNotes(
		mapAnnotations: [NoteMapAnnotation],
		notes: [UUID: any NoteProtocol],
		noteOverviews: [NoteOverview]
	) {
		self.store.noteOverviews = noteOverviews
		self.store.notes = notes
		self.store.noteOverviews = noteOverviews
	}

	func Sort(
		_ sort: NoteListSort,
		_ isAscending: Bool
	) {
		store.sort = sort
		store.sortAscending = isAscending
	}

	// MARK - private functions
	private func doError(_ message: String) {
		// TODO - raise this error properly to the UI layer
		Logger.foreground.error("UI-level error: \(message)")
	}
	private func doError(_ error: any Error) {
		// TODO - raise this error properly to the UI layer
		Logger.foreground.error("UI-level error: \(error)")
	}

	private func onFilterChange() {
		let asStrings: [String] = store.filterInstances.map { $1.toString() }
		UserDefaults.standard.set(asStrings, forKey: "filters")
		Logger.foreground.info("Saved filters \(asStrings)")
		//calculateNotesToShow()
	}

	private func loadFilters() {
		let fs = UserDefaults.standard.stringArray(forKey: "filters") ?? []
		for f in fs {
			guard let filter: FilterInstance = FilterInstance.fromString(f) else {
				Logger.background.error("Failed to parse filter string: \(f)")
				continue
			}
			self.store.filterInstances[filter.Name()] = filter
		}
	}

	private func shouldShow(_ note: AnyNote) -> Bool {
		for filter in store.filterInstances.values {
			if !filter.AllowsNote(note) {
				return false
			}
		}
		do {
			let coordinate = try cellToLatLng(cell: note.h3cell)
			if coordinate.latitude < store.currentRegion.minLatitude
				|| coordinate.longitude < store.currentRegion.minLongitude
				|| coordinate.latitude > store.currentRegion.maxLatitude
				|| coordinate.longitude > store.currentRegion.maxLongitude
			{
				return false
			}
			return true
		}
		catch {
			Logger.background.error("Failed to convert H3 cell to lat/lng: \(error)")
			return false
		}
	}
}

class NotesControllerPreview: NotesController {
	init(model: NotesStore = NotesStore()) {
		super.init()
		self.store = model
	}
}
