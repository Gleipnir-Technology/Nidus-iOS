import Foundation

/// Ties together a location and a time for tracking where a user went while they recorded audio
class AudioNoteBreadcrumb: Codable, Hashable {
	enum CodingKeys: CodingKey {
		case cell
		case created
	}

	let cell: H3Cell
	let created: Date

	init(cell: H3Cell, created: Date) {
		self.cell = cell
		self.created = created
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		cell = try container.decodeIfPresent(H3Cell.self, forKey: .cell)!
		created = try container.decodeIfPresent(Date.self, forKey: .created)!
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(cell, forKey: .cell)
		try container.encode(created, forKey: .created)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(cell)
		hasher.combine(created)
	}

	static func == (lhs: AudioNoteBreadcrumb, rhs: AudioNoteBreadcrumb) -> Bool {
		return lhs.created == rhs.created && lhs.cell == rhs.cell
	}
}
