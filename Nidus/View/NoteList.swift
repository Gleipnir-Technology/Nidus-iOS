import CoreLocation
import OSLog
import SwiftData
import SwiftUI

/*
 A view of the various notes in the current area
 */
struct NoteListView: View {
	var controller: NotesController
	let userLocation: H3Cell?

	@State var searchText: String = ""

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
							controller: controller,
							userLocation: userLocation
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
	let userLocation: H3Cell?

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
				ForEach(controller.model.noteOverview!, id: \.self) { overview in
					NoteListRow(overview: overview, userLocation: userLocation)
				}
			}
		}
	}
}

struct NoteListRow: View {
	let ROW_HEIGHT: CGFloat = 40.0
	let overview: NoteOverview
	let userLocation: H3Cell?
	var body: some View {
		HStack {
			Image(systemName: overview.icon).font(.system(size: 42.0)).background(
				Color.purple.opacity(0.3)
			).frame(width: 60, height: ROW_HEIGHT)
			NoteListRowIconCluster(icons: overview.icons).background(
				Color.red.opacity(0.3)
			).frame(width: 150, height: ROW_HEIGHT)
			Spacer()
			NoteListRowTextCluster(overview: overview, userLocation: userLocation)
				.background(
					Color.cyan.opacity(0.3)
				)
			Rectangle().foregroundStyle(overview.color).cornerRadius(10).frame(
				width: 10,
				height: .infinity
			).padding(.zero).offset(x: 20)
		}
	}
}

struct NoteListRowIconCluster: View {
	let iconsPerRow = 7
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
		Grid(horizontalSpacing: 1, verticalSpacing: 1) {
			GridRow {
				ForEach(0..<iconsPerRow, id: \.self) { index in
					if index < numIcons {
						let i = index
						let offset_y: CGFloat = 0  //(row == 0 ? -10 : 10)
						let offset_x: CGFloat = 0  //CGFloat(-10 * i)
						Image(systemName: icons[i])
							.offset(x: offset_x, y: offset_y)
					}
					else {
						Color.white.opacity(0.0)
					}
				}
			}
			GridRow {
				ForEach(0..<iconsPerRow, id: \.self) { index in
					if index + iconsPerRow < numIcons {
						let i = index + iconsPerRow
						let offset_y: CGFloat = 0  //(row == 0 ? -10 : 10)
						let offset_x: CGFloat = 10  //CGFloat(-10 * i)
						Image(systemName: icons[i])
							.offset(x: offset_x, y: offset_y)
					}
					else {
						//Color.blue
						Spacer()
					}
				}
			}
		}
	}
}

struct NoteListRowTextCluster: View {
	@Environment(\.locale) var locale
	let overview: NoteOverview
	let userLocation: H3Cell?

	var distanceDisplay: some View {
		/*let distance = Measurement(
            value: overview.location.distance(from: userLocation),
            unit: UnitLength.meters
        )

         return Text("\(distance, formatter: LengthFormatter())")*/
		if userLocation == nil {
			return Text("")
		}
		else {
			return Text("bar")
		}
	}
	var timeDisplay: some View {
		return Text("foo")
	}
	var body: some View {
		VStack {
			timeDisplay
			distanceDisplay
		}.backgroundStyle(.red.opacity(0.3))
	}
}

struct NoteList_Previews: PreviewProvider {
	static var previews: some View {
		NoteListView(
			controller: NotesControllerPreview(
				model: NotesModel(
					noteOverview: NotesModel.Preview.someNoteOverview
				)
			),
			userLocation: 0
		).previewDisplayName("base")
	}
}
