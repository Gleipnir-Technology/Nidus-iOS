import SwiftUI

enum AudioTagCategory: String, CaseIterable {
	case action
	case contact
	case followup
	case observation
}

struct AudioTagIdentifier {
	let category: AudioTagCategory
	let text: String

	static func parseTags(_ transcription: String) -> [AudioTagMatch] {
		var results: [AudioTagMatch] = []
		for identifier in AUDIO_TAG_IDENTIFIERS {
			let ranges = transcription.ranges(of: identifier.text)
			for range in ranges {
				results.append(
					AudioTagMatch(
						category: identifier.category,
						range: range,
						text: identifier.text
					)
				)
			}
		}
		return results
	}
}

let AUDIO_TAG_IDENTIFIERS: [AudioTagIdentifier] = [
	AudioTagIdentifier(category: .action, text: "five dips"),
	AudioTagIdentifier(category: .action, text: "checked trap"),
	AudioTagIdentifier(category: .action, text: "treated"),
	AudioTagIdentifier(category: .contact, text: "foreman"),
	AudioTagIdentifier(category: .contact, text: "Jim"),
	AudioTagIdentifier(category: .followup, text: "next week"),
	AudioTagIdentifier(category: .observation, text: "depression"),
	AudioTagIdentifier(category: .observation, text: "drain"),
	AudioTagIdentifier(category: .observation, text: "92 degrees"),
	AudioTagIdentifier(category: .observation, text: "full sun"),
	AudioTagIdentifier(category: .observation, text: "deep ruts"),
	AudioTagIdentifier(category: .observation, text: "still wet"),
	AudioTagIdentifier(category: .observation, text: "holding water"),
	AudioTagIdentifier(category: .action, text: "larvae"),
	AudioTagIdentifier(category: .action, text: "fourth instar"),
]

struct AudioTagMatch: Hashable {
	let category: AudioTagCategory
	let range: Range<String.Index>
	let text: String

	func color() -> Color {
		switch category {
		case .action:
			return .green
		case .contact:
			return .purple
		case .followup:
			return .cyan
		case .observation:
			return .brown
		}
	}

	init(category: AudioTagCategory, text: String) {
		self.category = category
		self.range = text.startIndex..<text.endIndex
		self.text = text
	}

	init(category: AudioTagCategory, range: Range<String.Index>, text: String) {
		self.category = category
		self.range = range
		self.text = text
	}

	struct Preview {
		static let tags: [AudioTagMatch] = [
			AudioTagMatch(category: .followup, text: "next week"),
			AudioTagMatch(category: .contact, text: "foreman"),
			AudioTagMatch(category: .contact, text: "James"),
			AudioTagMatch(category: .observation, text: "depression"),
			AudioTagMatch(category: .observation, text: "drain"),
			AudioTagMatch(category: .action, text: "dipped"),
			AudioTagMatch(category: .action, text: "checked trap"),
		]
	}
}
