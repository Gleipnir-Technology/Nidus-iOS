import CoreLocation
import H3
import OSLog
import SwiftData
import SwiftUI

/// A view of the various notes in the current area
struct NoteListView: View {
	let cell: H3Cell
	var controller: RootController
	let userLocation: H3Cell?

	@State var searchText: String = ""

	var body: some View {
		VStack {
			//NoteSearchBar(searchText: $searchText)

			if controller.notes.model.noteOverview == nil {
				Text("Loading")
			}
			else {
				if controller.notes.model.noteOverview!.count == 0 {
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

struct NoteList: View {
	var controller: RootController
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
		if controller.notes.model.noteOverview == nil {
			ProgressView()
		}
		else {
			List {
				ForEach(controller.notes.model.noteOverview!) { overview in
					NoteListRow(
						controller: controller,
						overview: overview,
						userLocation: userLocation
					)
				}
			}
		}
	}
}

struct NoteListRow: View {
	let ROW_HEIGHT: CGFloat = 40.0

	let controller: RootController
	let overview: NoteOverview
	let userLocation: H3Cell?
	var body: some View {
		NavigationLink(
			destination: NoteDetailView(
				controller: controller,
				noteUUID: overview.id
			)
		) {
			HStack {
				overview.icon.font(.system(size: 42.0))
					.frame(width: 80, height: ROW_HEIGHT)
				NoteListRowIconCluster(icons: overview.icons)
					.frame(width: 130, height: ROW_HEIGHT)
				Spacer()
				NoteListRowTextCluster(
					overview: overview,
					userLocation: userLocation
				).frame(width: 80, height: ROW_HEIGHT)
				Rectangle().foregroundStyle(overview.color).cornerRadius(10).frame(
					width: 10,
					height: ROW_HEIGHT
				).padding(.zero).offset(x: 28)
			}
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

	func createdFormatted(_ created: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .abbreviated
		let relativeDate = formatter.localizedString(for: created, relativeTo: Date.now)
		return relativeDate
	}

	var distanceDisplay: some View {
		if userLocation == nil {
			return Text("")
		}
		do {
			let userLatLng = try cellToLatLng(cell: userLocation!)
			let noteLatLng = try cellToLatLng(cell: overview.location)
			let distance = Measurement(
				value: userLatLng.distance(from: noteLatLng),
				unit: UnitLength.meters
			)
			let text = distance.formatted(
				.measurement(width: .abbreviated, usage: .road).locale(locale)
			)
			return Text("\(text)")
		}
		catch {
			Logger.foreground.warning("Failed to calculate distance: \(error)")
			return Text("")
		}
	}
	var timeDisplay: some View {
		return Text("\(createdFormatted(overview.time))")
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
			cell: 0x88_2834_7053f_ffff,
			controller: RootControllerPreview(
				notes: NotesControllerPreview(
					model: NotesModel.Preview.someNotes
				)
			),
			userLocation: RegionControllerPreview.userCell
		).previewDisplayName("base")
	}
}
