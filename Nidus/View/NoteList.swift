import CoreLocation
import H3
import OSLog
import SwiftData
import SwiftUI

/// A view of the various notes in the current area
struct NoteListView: View {
	var controller: RootController
	let selectedCell: H3Cell?
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
						controller: controller,
						selectedCell: selectedCell,
						userLocation: userLocation
					)
				}
			}
			Spacer()
		}
	}
}

/// Return the ordered list of overviews that are contained within the current cell
func overviewsInCellOrdered(
	controller: RootController,
	selectedCell: H3Cell?,
	userLocation: H3Cell?
)
	-> [NoteOverview]
{
	var results: [NoteOverview] = []
	let currentResolution = 13  //getResolution(cell: cell)
	for o in controller.notes.model.noteOverviews! {
		// No location for this note
		if o.location == 0 {
			continue
		}
		else if o.location == selectedCell {
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
				if c == selectedCell {
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
				"Got a location cell that is smaller that tapped cell \(String(selectedCell ?? 0, radix: 16)), not sure what to do with this: \(String(o.location, radix: 16))"
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

private struct NoteList: View {
	var controller: RootController
	let overviewsOrdered: [NoteOverview]
	let selectedCell: H3Cell?
	let userLocation: H3Cell?

	init(controller: RootController, selectedCell: H3Cell?, userLocation: H3Cell?) {
		self.controller = controller
		self.selectedCell = selectedCell
		self.overviewsOrdered = overviewsInCellOrdered(
			controller: controller,
			selectedCell: selectedCell,
			userLocation: userLocation
		)
		self.userLocation = userLocation
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

private struct NoteListRow: View {
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
			NoteListRowContent(overview: overview, userLocation: userLocation)
		}
	}
}
private struct NoteListRowContent: View {
	let ROW_HEIGHT: CGFloat = 40.0

	let overview: NoteOverview
	let userLocation: H3Cell?
	var body: some View {
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

private struct NoteListRowIconCluster: View {
	let iconsPerRow = 7
	let icons: Set<NoteOverviewIcon>

	func calculateIconsPerRow(_ numIcons: Int) -> (Int, Int) {
		if numIcons <= 2 { return (numIcons, 0) }
		if numIcons % 2 == 0 {
			return (numIcons / 2, numIcons / 2)
		}
		else {
			return ((numIcons + 1) / 2, (numIcons - 1) / 2)
		}
	}

	func toImage(_ icon: NoteOverviewIcon) -> some View {
		let placeholder = Image(systemName: "photo.fill").foregroundStyle(
			.primary,
			.red,
			.blue
		)
		switch icon {
		case .HasComments:
			return Image(systemName: "quote.bubble").foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .HasHabitat:
			return Image(systemName: "tree.fill").foregroundStyle(.primary, .red, .blue)
		case .HasInspections:
			return Image(systemName: "pencil.and.list.clipboard").foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .HasNextActionScheduled:
			return Image(systemName: "calendar.and.person").foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .HasTreatments:
			return Image(systemName: "pill.circle.fill").foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .HasUseType:
			return Image(systemName: "house.fill").foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .HasWaterOrigin:
			return Image(systemName: "water.waves").foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .SourceActive:
			return Image(systemName: "plus.circle.fill").foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .AbundanceTrendUp:
			return Image(.bargraphUp).resizable().foregroundStyle(.primary, .red, .blue)
		case .AbundanceTrendDown:
			return placeholder
		case .AggressiveAnimal:
			return Image(.dogSideview).resizable().foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .CallInAdvance:
			return Image(systemName: "phone.connection").symbolRenderingMode(
				.multicolor
			).foregroundStyle(.primary, .red, .blue)
		case .CompleteDataIndicator:
			return placeholder
		case .ContactInformationAvailable:
			return Image(systemName: "person.crop.circle").foregroundStyle(
				.primary,
				.red,
				.blue
			)
		case .FacilitatorIndicator:
			return placeholder
		case .FollowupScheduled:
			return Image(systemName: "calendar.and.person").symbolRenderingMode(
				.multicolor
			).foregroundStyle(.primary, .red, .blue)
		case .InteractionsNoted:
			return placeholder
		case .RootCauseIndicator:
			return placeholder
		case .PartOfCluster:
			return placeholder
		case .PreviousTreatmentFailure:
			return placeholder
		case .ProbabilityDeterminedByObservation:
			return placeholder
		case .ProblematicResident:
			return placeholder
		case .SpeciesFoundPreviously:
			return placeholder
		case .SourceProbabilityIndicator:
			return placeholder
		}
	}

	var body: some View {
		Grid(horizontalSpacing: 3, verticalSpacing: 1) {
			GridRow {
				ForEach(0..<iconsPerRow, id: \.self) { index in
					if icons.contains(NoteOverviewIcon.allCases[index]) {
						toImage(NoteOverviewIcon.allCases[index]).frame(
							width: 20,
							height: 20
						)
					}
					else {
						Spacer()
					}
				}
			}
			GridRow {
				ForEach(0..<iconsPerRow, id: \.self) { index in
					if icons.contains(NoteOverviewIcon.allCases[index]) {
						toImage(NoteOverviewIcon.allCases[index]).frame(
							width: 20,
							height: 20
						)
					}
					else {
						Spacer()
					}
				}
			}
		}
	}
}

private struct NoteListRowTextCluster: View {
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
			controller: RootControllerPreview(
				notes: NotesControllerPreview(
					model: NotesModel.Preview.noNotes
				)
			),
			selectedCell: 0x88_2834_7053f_ffff,
			userLocation: RegionControllerPreview.userCell
		)
		NoteListView(
			controller: RootControllerPreview(
				notes: NotesControllerPreview(
					model: NotesModel.Preview.someNotes
				)
			),
			selectedCell: 0x88_2834_7053f_ffff,
			userLocation: RegionControllerPreview.userCell
		).previewDisplayName("base")
		NavigationView {
			NoteListView(
				controller: RootControllerPreview(
					notes: NotesControllerPreview(
						model: NotesModel.Preview.notesWithIcons
					)
				),
				selectedCell: 0x88_2834_7053f_ffff,
				userLocation: RegionControllerPreview.userCell
			)
		}.previewDisplayName("icons")
		NoteListRowContent(
			overview: noteOverviewPreview(
				[.AbundanceTrendUp, .SourceProbabilityIndicator]
			),
			userLocation: RegionControllerPreview.userCell
		).previewDisplayName("just icons")
	}
}
