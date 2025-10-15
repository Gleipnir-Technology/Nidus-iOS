import MapKit
import OSLog
import SwiftUI

/*
 Controller for the set of notes we're working with
 */
@Observable
class NotesController {
	var model = NotesModel()

	func filterAdd(_ instance: FilterInstance) {
		model.filterInstances[instance.Name()] = instance
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
		self.model.noteOverviews = noteOverviews
		self.model.notes = notes
		self.model.noteOverviews = noteOverviews
	}

	func Sort(
		_ sort: NoteListSort,
		_ isAscending: Bool
	) {
		model.sort = sort
		model.sortAscending = isAscending
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
		let asStrings: [String] = model.filterInstances.map { $1.toString() }
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
			self.model.filterInstances[filter.Name()] = filter
		}
	}
	func handleNoteUpdates(_ response: NotesResponse) async {
		/*
        do {
        }
        catch {
            Logger.background.error("Failed to handle API response: \(error)")
        }
        */
	}

	private func shouldShow(_ note: AnyNote) -> Bool {
		for filter in model.filterInstances.values {
			if !filter.AllowsNote(note) {
				return false
			}
		}
		if note.coordinate.latitude < model.currentRegion.minLatitude
			|| note.coordinate.longitude < model.currentRegion.minLongitude
			|| note.coordinate.latitude > model.currentRegion.maxLatitude
			|| note.coordinate.longitude > model.currentRegion.maxLongitude
		{
			return false
		}
		return true
	}
}

class NotesControllerPreview: NotesController {
	init(model: NotesModel = NotesModel()) {
		super.init()
		self.model = model
	}
}
