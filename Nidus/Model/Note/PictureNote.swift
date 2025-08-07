import Foundation

struct PictureNote: NoteProtocol {
	var category: NoteType

	var timestamp: Date

	let id: UUID
	var location: H3Cell
	var overview: NoteOverview {
		return NoteOverview(
			color: .cyan,
			icon: "photo",
			icons: [],
			location: 0,
			time: Date.now
		)
	}
}
