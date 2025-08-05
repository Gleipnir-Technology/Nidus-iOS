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
				color: .gray,
				icon: "star",
				icons: [],
				time: Date.now - 60
			),
			NoteOverviewFlat(
				color: .purple,
				icon: "star",
				icons: ["figure.baseball.circle"],
				time: Date.now - 124
			),
			NoteOverviewFlat(
				color: .cyan,
				icon: "star",
				icons: ["figure.baseball.circle", "figure.roll.circle.fill"],
				time: Date.now - 392
			),
			NoteOverviewFlat(
				color: .yellow,
				icon: "star",
				icons: [
					"figure.baseball.circle", "figure.roll.circle.fill",
					"figure.walk.treadmill",
				],
				time: Date.now - 334
			),
			NoteOverviewFlat(
				color: .green,
				icon: "star",
				icons: [
					"figure.barre.circle", "figure.baseball.circle",
					"figure.roll.circle.fill", "figure.walk.treadmill",
				],
				time: Date.now - 3600
			),
			NoteOverviewFlat(
				color: .blue,
				icon: "star",
				icons: [
					"figure.handball.circle",
					"figure.highintensity.intervaltraining.circle",
					"figure.hunting.circle.fill", "figure.ice.hockey",
					"figure.indoor.cycle.circle",
				],
				time: Date.now - 3600
			),
			NoteOverviewFlat(
				color: .blue,
				icon: "star",
				icons: [
					"figure.handball.circle",
					"figure.highintensity.intervaltraining.circle",
					"figure.hunting.circle.fill", "figure.ice.hockey",
					"figure.indoor.cycle.circle", "figure.bowling.circle",
					"figure.boxing.circle.fill", "figure.core.training.circle",
					"figure.cricket.circle.fill", "figure.disc.sports.circle",
					"figure.skiing.downhill.circle",
				],
				time: Date.now - 3600
			),
		]
	}
}
