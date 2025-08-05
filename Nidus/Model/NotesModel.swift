import MapKit

struct NotesModel {
	var currentRegion: MKCoordinateRegion = Initial.region
	var errorMessage: String? = nil
	var filterInstances: [String: FilterInstance] = [:]
	var notes: [UUID: AnyNote]? = nil
	var noteOverview: [NoteOverviewFlat]? = []
	var searchText: String = ""
	struct Preview {
		static let someNoteOverview: [NoteOverviewFlat] = [
			NoteOverviewFlat(
				color: .green,
				icon: "star",
				icons: ["star", "star"],
				time: Date.now - 3600
			)
		]
	}
}
