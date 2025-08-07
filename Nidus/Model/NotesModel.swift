import MapKit

struct NotesModel {
	var currentRegion: MKCoordinateRegion = Initial.region
	var errorMessage: String? = nil
	var filterInstances: [String: FilterInstance] = [:]
	var notes: [UUID: AnyNote]? = nil
	var noteOverview: [NoteOverview]? = []
	var searchText: String = ""
	struct Preview {
		static let someNoteOverview: [NoteOverview] = []
	}
}
