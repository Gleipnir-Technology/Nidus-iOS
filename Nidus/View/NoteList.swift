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
				NoteSearchBar(searchText: $searchText)

				if controller.model.noteOverview == nil {
					Text("Loading")
				}
				else {
					if controller.model.noteOverview!.count == 0 {
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
		}
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
		if controller.model.noteOverview == nil {
			ProgressView()
		}
		else {
			List {
				ForEach(controller.model.noteOverview!) { overview in
					NoteListRow(overview: overview)
				}
			}
		}
	}
}

struct NoteListRow: View {
	let overview: any NoteOverview
	var body: some View {
		HStack {
			Image(systemName: overview.icon).font(.system(size: 42.0))
			NoteListRowIconCluster(icons: overview.icons)
			Spacer()
			NoteListRowTextCluster(overview: overview)
		}
	}
}

struct NoteListRowTextCluster: View {
	let overview: any NoteOverview
	var body: some View {
		VStack {
			Text("1 min ago")
			Text("20m away")
		}
	}
}
struct NoteListRowIconCluster: View {
	let icons: [String]

	func calculateIconsPerRow(_ numIcons: Int) -> (Int, Int) {
		if numIcons <= 2 { return (numIcons, 0) }
		if numIcons % 2 == 0 {
			return (numIcons / 2, numIcons / 2)
		}
		else {
			return ((numIcons + 1) / 2, (numIcons - 1) / 2)
		}
	}

	var body: some View {
		let numIcons = icons.count
		let iconsPerRow = calculateIconsPerRow(numIcons)
		LazyVGrid(columns: [GridItem(.adaptive(minimum: 10))], spacing: 10) {
			ForEach(0..<numIcons, id: \.self) { index in
				let i: Int = index
				let row: Int = ((i % 2) == 0) ? 0 : 1
				//let offset: CGFloat = (row == 0 ? 0 : CGFloat(iconsPerRow[0] / 2.5))
				let offset_y: CGFloat = (row == 0 ? -10 : 10)
				let offset_x: CGFloat = CGFloat(-10 * i)
				//Text("r\(row) o\(offset)")
				Image(systemName: icons[index])
					.frame(width: 50, height: 50)
					.offset(x: offset_x, y: offset_y)
				/*
					.offset(y: row == 1 ? offset : -offset)*/
			}
		}
	}
}
struct NoteList_Previews: PreviewProvider {
	static var previews: some View {
		NoteListView(
			controller: NotesControllerPreview(
				model: NotesModel(
					noteOverview: NotesModel.Preview.someNoteOverview
				)
			)
		).previewDisplayName("base")
	}
}
