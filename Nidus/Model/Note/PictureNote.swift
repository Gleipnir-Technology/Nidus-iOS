import Foundation

struct PictureNote: NoteProtocol {
	let id: UUID
	var location: H3Cell
	var timestamp: Date

	init(location: H3Cell, timestamp: Date = Date()) {
		self.id = UUID()
		self.location = location
		self.timestamp = timestamp
	}

	var category: NoteType {
		return .picture
	}
	var overview: NoteOverview {
		return NoteOverview(
			color: .cyan,
			icon: "photo",
			icons: [],
			location: location,
			time: Date.now
		)
	}
}
