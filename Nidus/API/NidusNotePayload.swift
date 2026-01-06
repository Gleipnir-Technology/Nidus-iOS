import Foundation

struct NidusNotePayload: Codable {
	let audio: [AudioPayload]
	let h3cell: H3Cell
	let images: [ImagePayload]
	let text: String
	let timestamp: Date
	let uuid: UUID
}
