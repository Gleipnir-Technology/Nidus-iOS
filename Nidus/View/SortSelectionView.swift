import OSLog
import SwiftUI

enum NoteListSort {
	case Age
	case DistanceFromSelection
	case DistanceFromUser
}

struct SortSelectionView: View {
	@State var selection: Int = 0
	@State var ascending: Bool = true
	func apply() {
		Logger.foreground.info("Apply sort")
	}
	var body: some View {
		Form {
			Picker(
				selection: $selection,
				label: Text("Sort notes by"),
				content: {
					Text("Note age").tag(0)
					Text("Distance from selected location").tag(1)
					Text("Distance from user location").tag(2)
				}
			)
			Picker(
				selection: $ascending,
				label: Text("Ascending"),
				content: {
					Text("Ascending").tag(true)
					Text("Descending").tag(false)
				}
			)
		}.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button("Apply") {
					apply()
				}
			}
		}
	}
}

#Preview {
	NavigationStack {
		SortSelectionView()
	}
}
