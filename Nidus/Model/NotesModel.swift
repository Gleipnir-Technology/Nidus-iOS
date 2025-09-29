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
		static let noNotes: NotesModel = NotesModel.forPreview(notes: [])
		static let notesWithIcons: NotesModel = NotesModel.forPreview(notes: [
			MosquitoSourceNote(
				access: "",
				active: false,
				comments: "",
				created: Date.now.advanced(by: -30 * 60 * 24 * 25),
				description: "",
				habitat: "",
				id: UUID(),
				inspections: [],
				lastInspectionDate: Date.now.advanced(by: -300),
				location: 0x8a2_8347_0522_ffff,
				name: "",
				nextActionDateScheduled: Date.now.advanced(by: -300),
				treatments: [],
				useType: "",
				waterOrigin: "sure",
				zone: ""
			),
			MosquitoSourceNote(
				access: "",
				active: true,
				comments: "yes",
				created: Date.now.advanced(by: -30 * 60 * 24 * 98),
				description: "",
				habitat: "",
				id: UUID(),
				inspections: [],
				lastInspectionDate: Date.now.advanced(by: -300),
				location: 0x8a2_8347_0526_7fff,
				name: "",
				nextActionDateScheduled: Date.now.advanced(by: -300),
				treatments: [],
				useType: "",
				waterOrigin: "",
				zone: ""
			),
			MosquitoSourceNote(
				access: "",
				active: false,
				comments: "yes",
				created: Date.now.advanced(by: -30 * 60 * 24 * 210),
				description: "",
				habitat: "yep",
				id: UUID(),
				inspections: [],
				lastInspectionDate: Date.now.advanced(by: -300),
				location: 0x8b2_8347_0534_afff,
				name: "",
				nextActionDateScheduled: Date.now.advanced(by: -300),
				treatments: [],
				useType: "",
				waterOrigin: "",
				zone: ""
			),
		])
		static let someNotes: NotesModel = NotesModel.forPreview(notes: [
			AudioNote(
				breadcrumbs: [
					AudioNoteBreadcrumb(
						cell: 0x8a2_8347_0531_7fff,
						created: Date.now.advanced(by: -30)
					)
				],
				duration: 12,
				version: 1
			),
			PictureNote.forPreview(location: 0x8a2_8347_0531_4fff),
		])
		static let someNoteOverview: [NoteOverview] = []
	}
}
