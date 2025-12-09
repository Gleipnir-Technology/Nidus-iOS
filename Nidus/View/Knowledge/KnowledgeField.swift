import SwiftUI

private struct KnowledgeFieldComplete: View {
	let name: String
	let value: String

	var font: Font { .system(size: 13) }
	var body: some View {
		HStack {
			Image(systemName: "checkmark.square")
			Text(name).font(font).gridColumnAlignment(.leading)
				.foregroundStyle(
					Color.primary.opacity(0.5)
				)
			Text(value).font(font).gridColumnAlignment(
				.leading
			).foregroundStyle(Color.primary.opacity(0.7))
		}.listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))
	}
}
private struct KnowledgeFieldIncomplete: View {
	let name: String
	let prompt: String
	var promptChoices: [String] = []
	let value: String

	var font: Font { .system(size: 13) }

	var body: some View {
		HStack {
			Image(systemName: "square")
			Text(name).font(font).gridColumnAlignment(.leading)
				.foregroundStyle(Color.primary)
			if promptChoices.isEmpty {
				Text("\"\(prompt)\"").font(font).gridColumnAlignment(
					.leading
				).padding(.vertical, 2)
			}
			else {
				ScrollView {
					VStack {
						ForEach(promptChoices, id: \.self) {
							promptChoice in
							Text(promptChoice).font(font).frame(
								maxWidth: 200,
								alignment: .leading
							)
						}
					}
				}.frame(height: 150).border(Color.gray.opacity(0.3))
			}
		}.listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))
	}
}

struct KnowledgeField: View {
	let name: String
	let prompt: String
	var promptChoices: [String] = []
	let isDone: Bool
	let value: String

	var body: some View {
		if isDone {
			KnowledgeFieldComplete(name: name, value: value)
		}
		else {
			KnowledgeFieldIncomplete(
				name: name,
				prompt: prompt,
				promptChoices: promptChoices,
				value: value
			)
		}
	}
}
