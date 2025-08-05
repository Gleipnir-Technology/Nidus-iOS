import SwiftUI

/*
 The bar that contains the search area and the filter area
 */
struct NoteSearchBar: View {
	@State var active = false
	@FocusState var isSearchFieldFocused: Bool
	@Binding var searchText: String
	var body: some View {
		HStack {
			HStack {
				Image(systemName: "magnifyingglass").foregroundColor(.gray)
				TextField(
					"Search",
					text: $searchText,
					onEditingChanged: { editing in
						withAnimation {
							active = editing
						}
					}
				).focused($isSearchFieldFocused)
			}
			.padding(7)
			.background(Color(white: 0.9))
			.cornerRadius(10)
			.padding(.horizontal, active ? 0 : 50)

			.opacity(active ? 1 : 0)
			.frame(width: active ? nil : 0)
			Spacer()
			if active {
				Button("Cancel") {
					withAnimation {
						active = false
						isSearchFieldFocused = false
					}
				}
			}
			else {
				NoteFilterButton()
			}
		}.padding()
	}
}
