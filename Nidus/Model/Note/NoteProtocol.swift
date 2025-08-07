import Foundation

enum NoteType {
	case audio
	case mosquitoSource
	case picture
}

protocol NoteProtocol: Identifiable<UUID>, Hashable {
	var category: NoteType { get }
	var location: H3Cell { get }
	var id: UUID { get }
	var mapAnnotation: NoteMapAnnotation { get }
	var overview: NoteOverview { get }
	var timestamp: Date { get }
}

func iconForNoteType(_ type: NoteType) -> String {
	switch type {
	case .audio:
		return "waveform"
	case .mosquitoSource:
		return "ant.fill"
	case .picture:
		return "photo"
	}
}
