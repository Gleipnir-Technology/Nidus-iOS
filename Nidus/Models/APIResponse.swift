//
//  APIResponse.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/4/25.
//

struct LocationResponse: Codable {
	let latitude: Double
	let longitude: Double

	func asNoteLocation() -> NoteLocation {
		NoteLocation(latitude: latitude, longitude: longitude)
	}
}

final class APIResponse: Codable {
	enum CodingKeys: CodingKey {
		case requests
		case sources
		case traps
	}

	let requests: [ServiceRequest]
	let sources: [MosquitoSource]
	let traps: [TrapData]

	init(requests: [ServiceRequest], sources: [MosquitoSource], traps: [TrapData]) {
		self.requests = requests
		self.sources = sources
		self.traps = traps
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.requests = try container.decode([ServiceRequest].self, forKey: .requests)
		self.sources = try container.decode([MosquitoSource].self, forKey: .sources)
		self.traps = try container.decode([TrapData].self, forKey: .traps)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(requests, forKey: .requests)
		try container.encode(sources, forKey: .sources)
		try container.encode(traps, forKey: .traps)
	}
}
