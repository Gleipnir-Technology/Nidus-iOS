import Foundation

struct AudioNote: NoteProtocol {
	let id: UUID
	var location: H3Cell
	var timestamp: Date

	init(location: H3Cell, timestamp: Date = Date()) {
		self.id = UUID()
		self.location = location
		self.timestamp = timestamp
	}

	var category: NoteType {
		return .audio
	}

	var overview: NoteOverview {
		return NoteOverview(
			color: .red,
			icon: "waveform",
			icons: [],
			location: location,
			time: Date.now
		)
	}
}
