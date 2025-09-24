import SwiftUI

struct TagLabel {
	let color: Color
	let keyword: String
}

func TranscriptTagTypeToColor(_ type: TranscriptTagType) -> Color {
	switch type {
	case .Action:
		return .red
	case .Measurement:
		return .green
	case .Source:
		return .purple
	}
}

struct TranscriptionDisplay: View {
	let knowledgeGraph: KnowledgeGraph?
	let transcription: String?

	func attributedString(for text: String, knowledgeGraph: KnowledgeGraph?) -> AttributedString
	{
		var attributedString = AttributedString(text)
		guard let knowledgeGraph else { return attributedString }
		for tag in knowledgeGraph.transcriptTags {
			if let attributedRange = Range(
				NSRange(tag.range, in: text),
				in: attributedString
			) {
				attributedString[attributedRange].foregroundColor =
					TranscriptTagTypeToColor(tag.type)
			}
		}
		return attributedString
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				if transcription == nil {
					Text("no transcription").id("transcription")
				}
				else {
					Text(
						attributedString(
							for: transcription!,
							knowledgeGraph: knowledgeGraph
						)
					)
					.frame(
						maxWidth: .infinity,
						maxHeight: 200,
						alignment: .leading
					)
					.font(.caption)
					.id("transcription")
				}
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

private func previewFromTranscript(_ text: String) -> TranscriptionDisplay {
	let knowledgeGraph: KnowledgeGraph = ExtractKnowledge(text)
	return TranscriptionDisplay(
		knowledgeGraph: knowledgeGraph,
		transcription: text
	)
}

#Preview {
	previewFromTranscript(
		"This bucket of green water may be a mosquito source. We should check back next week."
	)
}
