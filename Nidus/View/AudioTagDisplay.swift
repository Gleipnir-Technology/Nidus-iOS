import SwiftUI

struct AudioTagDisplay: View {
	@Namespace private var namespace
	let tags: [AudioTagMatch]

	var body: some View {
		if tags.count == 0 {
			Spacer()
		}
		else {
			List {
				AudioTagDisplayCategory(
					category: .action,
					icon: "bolt",
					tags: tags.filter { $0.category == .action }
				)
				AudioTagDisplayCategory(
					category: .contact,
					icon: "person.fill",
					tags: tags.filter { $0.category == .contact }
				)
				AudioTagDisplayCategory(
					category: .followup,
					icon: "calendar.circle",
					tags: tags.filter { $0.category == .followup }
				)
				AudioTagDisplayCategory(
					category: .observation,
					icon: "note",
					tags: tags.filter { $0.category == .observation }
				)
			}.listStyle(GroupedListStyle()).environment(\.horizontalSizeClass, .regular)
		}
	}
}

struct AudioTagDisplayCategory: View {
	@Namespace private var namespace
	let category: AudioTagCategory
	let icon: String
	let tags: [AudioTagMatch]

	var header: some View {
		HStack {
			Image(systemName: icon)
			Text(category.rawValue.capitalized)
		}
	}

	var body: some View {
		if tags.count == 0 {
			EmptyView()
		}
		else {
			Section(header: header) {
				ForEach(tags, id: \.self) { tag in
					Text(tag.text)
						.matchedGeometryEffect(id: tag, in: namespace)
				}
			}.animation(.smooth(duration: 1.0), value: tags)
		}
	}
}

#Preview {
	AudioTagDisplay(
		tags: AudioTagMatch.Preview.tags
	)
}
