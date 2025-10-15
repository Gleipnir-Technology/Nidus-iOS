import SwiftUI

enum NoteListSort {
	case Age
	case DistanceFromSelection
	case DistanceFromUser
}

struct SortSelectionView: View {
	@State var selection: Int = 0
	var body: some View {
		Picker(
			selection: $selection,
			label: Text("Note Sort"),
			content: {
				Text("Note age").tag(0)
				Text("Distance from selected location").tag(1)
				Text("Distance from user location").tag(2)
			}
		)
	}
}
