import OSLog
import SwiftUI

struct SortSelectionView: View {
	@State var ascending: Bool = true
	var controller: NotesController
	@Environment(\.dismiss) private var dismiss
	@State var selection: Int = 0

	func apply() {
		do {
			let sort: NoteListSort = try NoteListSort.FromInt(selection)
			controller.Sort(sort, ascending)
		}
		catch {
			Logger.background.error(
				"Failed to parse sort selection from \(selection). This is a programmer error"
			)
		}
	}

	var body: some View {
		Form {
			Picker(
				selection: $selection,
				label: Text("Sort notes by"),
				content: {
					Text("Note age").tag(NoteListSort.Age.ToInt())
					Text("Distance from selected location").tag(
						NoteListSort.DistanceFromSelection.ToInt()
					)
					Text("Distance from user location").tag(
						NoteListSort.DistanceFromUser.ToInt()
					)
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
					dismiss()
				}
			}
		}.onAppear {
			self.ascending = controller.model.sortAscending
			self.selection = controller.model.sort.ToInt()
		}
	}
}

#Preview {
	NavigationStack {
		SortSelectionView(controller: NotesController())
	}
}
