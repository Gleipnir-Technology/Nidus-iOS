import SwiftUI

struct TagLabel {
	let color: Color
	let keyword: String
}

struct TranscriptionDisplay: View {
	let model: AudioModel

	func attributedString(for text: String, tags: [AudioTagMatch]) -> AttributedString {
		/*
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

		return attributedString*/
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
				Text(attributedString(for: model.transcription!, tags: model.tags))
					.frame(
						maxWidth: .infinity,
						maxHeight: 200,
						alignment: .leading
					)
					.font(.caption)
					.id("transcription")
			}.onChange(of: model.transcription) {
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
		model: AudioModel.fromTranscript(
			"This bucket of green water may be a mosquito source. We should check back next week."
		)
	)
}
