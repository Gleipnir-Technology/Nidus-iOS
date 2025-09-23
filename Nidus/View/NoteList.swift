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

			if controller.notes.model.noteOverviews == nil {
				Text("Loading")
			}
			else {
				if controller.notes.model.noteOverviews!.count == 0 {
					Text("No notes")
				}
				else {
					NoteList(
						cell: cell,
						controller: controller,
						userLocation: userLocation
					)
				}
			}
			Spacer()
		}
	}
}

/// Return the ordered list of overviews that are contained within the current cell
func overviewsInCellOrdered(cell: H3Cell, controller: RootController, userLocation: H3Cell?)
	-> [NoteOverview]
{
	var results: [NoteOverview] = []
	let currentResolution = getResolution(cell: cell)
	for o in controller.notes.model.noteOverviews! {
		// No location for this note
		if o.location == 0 {
			continue
		}
		else if o.location == cell {
			results.append(o)
			continue
		}
		let res = getResolution(cell: o.location)
		if res > currentResolution {
			do {
				let c = try scaleCell(
					o.location,
					to: UInt(currentResolution)
				)
				if c == cell {
					results.append(o)
				}
			}
			catch {
				Logger.foreground.error(
					"Failed to scale cell: \(o.location) to \(currentResolution): \(error)"
				)
			}
		}
		else if res == currentResolution {
			// We know from the first check above that they are different cells
			continue
		}
		else {
			Logger.foreground.warning(
				"Got a location cell that is smaller that tapped cell \(String(cell, radix: 16)), not sure what to do with this: \(String(o.location, radix: 16))"
			)
		}
	}
	// At this point we have a set of results, but they aren't in order
	if userLocation == nil {
		return results.sorted { (o1: NoteOverview, o2: NoteOverview) -> Bool in
			o1.time > o2.time
		}
	}
	return results.sorted { (o1: NoteOverview, o2: NoteOverview) -> Bool in
		do {
			let d1 = try gridDistance(
				origin: userLocation!,
				destination: o1.location
			)
			let d2 = try gridDistance(
				origin: userLocation!,
				destination: o2.location
			)
			if d1 == d2 {
				return o1.time > o2.time
			}
			return d1 > d2

		}
		catch {
			// effectively random
			return o1.time > o2.time
		}
	}
}

struct NoteList: View {
	let cell: H3Cell
	var controller: RootController
	let overviewsOrdered: [NoteOverview]
	let userLocation: H3Cell?

	init(cell: H3Cell, controller: RootController, userLocation: H3Cell?) {
		self.cell = cell
		self.controller = controller
		self.userLocation = userLocation
		self.overviewsOrdered = overviewsInCellOrdered(
			cell: cell,
			controller: controller,
			userLocation: userLocation
		)
	}

	var body: some View {
		if controller.notes.model.noteOverviews == nil {
			ProgressView()
		}
		else {
			List {
				if overviewsOrdered.count > 0 {
					ForEach(overviewsOrdered) { overview in
						NoteListRow(
							controller: controller,
							overview: overview,
							userLocation: userLocation
						)
					}
				}
				else {
					Text("No notes to show")
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
					model: NotesModel.Preview.noNotes
				)
			),
			userLocation: RegionControllerPreview.userCell
		)
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
