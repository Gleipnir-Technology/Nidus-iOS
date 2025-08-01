import SwiftUI

struct TagLabel {
	let color: Color
	let keyword: String
}

struct TranscriptionDisplay: View {
	let transcription: String

	let TAGS: [TagLabel] = [
		TagLabel(color: .green, keyword: "green water"),
		TagLabel(color: .red, keyword: "mosquito source"),
		TagLabel(color: .blue, keyword: "check back"),
		TagLabel(color: .yellow, keyword: "next week"),
	]

	func attributedString(for text: String) -> AttributedString {
		var attributedString = AttributedString(text)
		for tag in TAGS {
			let ranges = text.ranges(of: tag.keyword)
			for range in ranges {
				if let attributedRange = Range(
					NSRange(range, in: text),
					in: attributedString
				) {
					attributedString[attributedRange].foregroundColor =
						tag.color
				}
			}
		}

		return attributedString
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				Text(attributedString(for: transcription))
					.frame(
						maxWidth: .infinity,
						maxHeight: 200,
						alignment: .leading
					)
					.font(.caption)
					.id("transcription")
			}.onChange(of: transcription) {
				withAnimation(
					.easeInOut(duration: 0.3)
				) {
					proxy.scrollTo(
						"transcription",
						anchor: .bottom
					)
				}
			}.frame(maxHeight: 100)
		}

	}
}

#Preview {
	TranscriptionDisplay(
		transcription:
			"This bucket of green water may be a mosquito source. We should check back next week."
	)
}
