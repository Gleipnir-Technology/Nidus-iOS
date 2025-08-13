import SwiftUI

struct TagLabel {
	let color: Color
	let keyword: String
}

struct TranscriptionDisplay: View {
	let tags: [AudioTagMatch]
	let transcription: String?

	func attributedString(for text: String, tags: [AudioTagMatch]) -> AttributedString {
		var attributedString = AttributedString(text)
		for tag in tags {
			if let attributedRange = Range(
				NSRange(tag.range, in: text),
				in: attributedString
			) {
				attributedString[attributedRange].foregroundColor = tag.color()
			}
		}
		return attributedString
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				Text(attributedString(for: transcription!, tags: tags))
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
		tags: [],
		transcription:
			"This bucket of green water may be a mosquito source. We should check back next week."
	)
}
