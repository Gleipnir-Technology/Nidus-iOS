import MapKit

struct NotesModel {
	var currentRegion: MKCoordinateRegion = Initial.region
	var errorMessage: String? = nil
	var filterInstances: [String: FilterInstance] = [:]
	var notes: [UUID: any NoteProtocol]? = nil
	var noteOverview: [NoteOverview]? = []
	var searchText: String = ""

	static func forPreview(notes: [any NoteProtocol]) -> NotesModel {
		var model = NotesModel()
		model.notes = notes.reduce(into: [:]) { result, note in
			result[note.id] = note
		}
		model.noteOverview = notes.map { $0.overview }
		return model
	}

	struct Preview {
		static let someNotes: NotesModel = NotesModel.forPreview(notes: [
			AudioNote(location: 0),
			PictureNote(location: 0),
		])
		static let someNoteOverview: [NoteOverview] = []
	}
}
