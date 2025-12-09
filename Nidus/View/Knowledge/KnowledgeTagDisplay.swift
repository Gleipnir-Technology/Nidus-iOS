import SwiftUI

struct KnowledgeTagDisplay: View {
	let tags: Set<String>
	let columns = 3

	// Dictionary mapping specific tags to their custom colors
	var tagColors: [String: Color] = [:]

	// Default styling
	var defaultTagBackgroundColor: Color = Color(.systemGray5)
	var defaultTagTextColor: Color = .primary
	var tagCornerRadius: CGFloat = 8
	var tagPadding: CGFloat = 8
	var spacing: CGFloat = 10

	private var gridItems: [GridItem] {
		Array(repeating: .init(.flexible(), spacing: spacing), count: columns)
	}

	var body: some View {
		LazyVGrid(columns: gridItems, spacing: spacing) {
			ForEach(Array(tags).sorted(), id: \.self) { tag in
				Text(tag)
					.padding(.horizontal, tagPadding)
					.padding(.vertical, 6)
					.background(backgroundColor(for: tag))
					.foregroundColor(textColor(for: tag))
					.cornerRadius(tagCornerRadius)
					.lineLimit(1)
			}
		}
		.padding(.horizontal)
	}

	// Get the appropriate background color for a tag
	private func backgroundColor(for tag: String) -> Color {
		tagColors[tag.lowercased()]?.opacity(0.2) ?? defaultTagBackgroundColor
	}

	// Get the appropriate text color for a tag
	private func textColor(for tag: String) -> Color {
		tagColors[tag.lowercased()] ?? defaultTagTextColor
	}
}
