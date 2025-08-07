import Foundation

enum NoteType {
	case audio
	case picture
}

protocol NoteProtocol: Identifiable<UUID>, Hashable {
	var category: NoteType { get }
	var location: H3Cell { get }
	var id: UUID { get }
	var timestamp: Date { get }
}
