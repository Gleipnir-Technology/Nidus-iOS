import MapKit

struct NotesModel {
	var currentRegion: MKCoordinateRegion = Initial.region
	var errorMessage: String? = nil
	var filterInstances: [String: FilterInstance] = [:]
	var mapAnnotations: [NoteMapAnnotation] = []
	var notes: [UUID: any NoteProtocol]? = nil
	var noteOverviews: [NoteOverview]? = []
	var searchText: String = ""

	static func forPreview(notes: [any NoteProtocol]) -> NotesModel {
		var model = NotesModel()
		model.notes = notes.reduce(into: [:]) { result, note in
			result[note.id] = note
		}
		model.noteOverviews = notes.map { $0.overview }
		model.mapAnnotations = notes.map { $0.mapAnnotation }
		return model
	}

	struct Preview {
		static let someNotes: NotesModel = NotesModel.forPreview(notes: [
			AudioNote(
				breadcrumbs: [
					AudioNoteBreadcrumb(
						cell: 0x8a2_8347_0531_7fff,
						created: Date.now.advanced(by: -30)
					)
				],
				duration: 12
			),
			PictureNote.forPreview(location: 0x8a2_8347_0531_4fff),
		])
		static let someNoteOverview: [NoteOverview] = []
	}
}
