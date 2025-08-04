import CoreLocation
import OSLog
import SwiftData
import SwiftUI

/*
 A view of the various notes in the current area
 */
struct NoteListView: View {
	var controller: NotesController
	@State var searchText: String = ""

	init(controller: NotesController) {
		self.controller = controller
	}

	var body: some View {
		NavigationStack {
			VStack {
				HStack {
					NoteSearchBar()
					NoteFilterButton()
				}

				if controller.model.notes == nil {
					Text("Loading")
				}
				else {
					if controller.model.notes!.count == 0 {
						Text("No notes")
					}
					else {
						NoteList(
							controller: controller
						)
					}
				}
				Spacer()
			}
		}.searchable(text: $searchText)
	}
}

struct NoteList: View {
	var controller: NotesController

	func notesByDistance(_ notes: [AnyNote], currentLocation: CLLocation) -> [AnyNote] {
		var byDistance: [AnyNote] = notes
		byDistance.sort(by: { (an1: AnyNote, an2: AnyNote) -> Bool in
			return currentLocation.distance(
				from: CLLocation(
					latitude: an1.coordinate.latitude,
					longitude: an1.coordinate.longitude
				)
			)
				< currentLocation.distance(
					from: CLLocation(
						latitude: an2.coordinate.latitude,
						longitude: an2.coordinate.longitude
					)
				)
		})
		return byDistance
	}

	var body: some View {
		Text("some stuff")
	}
}

struct NoteList_Previews: PreviewProvider {
	static var previews: some View {
		NoteListView(
			controller: NotesController()
		).previewDisplayName("base")
	}
}
