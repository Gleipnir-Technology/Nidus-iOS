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
					category: .priority,
					icon: "bolt",
					tags: tags.filter { $0.category == .priority }
				)
				AudioTagDisplayCategory(
					category: .landCategory,
					icon: "mountain.2",
					tags: tags.filter { $0.category == .landCategory }
				)
				AudioTagDisplayCategory(
					category: .trapSite,
					icon: "trapezoid.and.line.vertical",
					tags: tags.filter { $0.category == .trapSite }
				)
				AudioTagDisplayCategory(
					category: .arbovirus,
					icon: "hazardsign",
					tags: tags.filter { $0.category == .arbovirus }
				)
				AudioTagDisplayCategory(
					category: .mosquitoSex,
					icon: "custom.mosquito.2",
					tags: tags.filter { $0.category == .mosquitoSex }
				)
				AudioTagDisplayCategory(
					category: .mosquitoStage,
					icon: "custom.mosquito.2",
					tags: tags.filter { $0.category == .mosquitoStage }
				)
				AudioTagDisplayCategory(
					category: .mosquitoTrap,
					icon: "custom.mosquito.2",
					tags: tags.filter { $0.category == .mosquitoTrap }
				)
				AudioTagDisplayCategory(
					category: .mosquitoTrapStatus,
					icon: "custom.mosquito.2",
					tags: tags.filter { $0.category == .mosquitoTrapStatus }
				)
				AudioTagDisplayCategory(
					category: .species,
					icon: "custom.mosquito.2",
					tags: tags.filter { $0.category == .species }
				)
				AudioTagDisplayCategory(
					category: .genus,
					icon: "custom.mosquito.2",
					tags: tags.filter { $0.category == .genus }
				)
				AudioTagDisplayCategory(
					category: .habitat,
					icon: "tree.circle",
					tags: tags.filter { $0.category == .habitat }
				)
				AudioTagDisplayCategory(
					category: .waterOrigin,
					icon: "drop.fill",
					tags: tags.filter { $0.category == .waterOrigin }
				)
				AudioTagDisplayCategory(
					category: .product,
					icon: "testtube.2",
					tags: tags.filter { $0.category == .product }
				)
				AudioTagDisplayCategory(
					category: .contactInfo,
					icon: "person",
					tags: tags.filter { $0.category == .contactInfo }
				)
				AudioTagDisplayCategory(
					category: .dataType,
					icon: "archivebox",
					tags: tags.filter { $0.category == .dataType }
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
