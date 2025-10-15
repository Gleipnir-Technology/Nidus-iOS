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
			NoteSearchBar(searchText: $searchText)

			if controller.notes.store.noteOverviews == nil {
				Text("Loading")
			}
			else {
				if controller.notes.store.noteOverviews!.count == 0 {
					Text("No notes")
				}
				else {
					NoteList(
						controller: controller,
						filterText: searchText,
						selectedCell: selectedCell,
						userLocation: userLocation
					)
				}
			}
			Spacer()
		}.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				NavigationLink {
					SortSelectionView(
						controller: controller.notes
					)
				} label: {
					Text("Sort")
				}
			}
		}
	}
}

/// Return the ordered list of overviews
func overviewsInAreaOrdered(
	isAscending: Bool,
	overviews: [NoteOverview],
	selectedLocation: H3Cell?,
	sort: NoteListSort,
	userLocation: H3Cell?
) -> [NoteOverview] {
	Logger.foreground.info("Sorting overviews with \(sort) and ascending \(isAscending)")
	switch sort {
	case .Age:
		return sortByAge(
			isAscending: isAscending,
			overviews: overviews
		)
	case .DistanceFromSelection:
		guard let selectedLocation else {
			guard let userLocation else {
				return sortByAge(isAscending: isAscending, overviews: overviews)
			}
			return sortByDistance(
				isAscending: isAscending,
				location: userLocation,
				overviews: overviews.filter({ $0.location != 0 })
			) + overviews.filter({ $0.location == 0 })
		}
		return sortByDistance(
			isAscending: isAscending,
			location: selectedLocation,
			overviews: overviews.filter({ $0.location != 0 })
		) + overviews.filter({ $0.location == 0 })
	case .DistanceFromUser:
		guard let userLocation = userLocation else {
			guard let selectedLocation else {
				return sortByAge(isAscending: isAscending, overviews: overviews)
			}
			return sortByDistance(
				isAscending: isAscending,
				location: selectedLocation,
				overviews: overviews.filter({ $0.location != 0 })
			) + overviews.filter({ $0.location == 0 })
		}
		return sortByDistance(
			isAscending: isAscending,
			location: userLocation,
			overviews: overviews.filter({ $0.location != 0 })
		) + overviews.filter({ $0.location == 0 })
	}
}
private func sortByAge(isAscending: Bool, overviews: [NoteOverview]) -> [NoteOverview] {
	let result = overviews.sorted { (o1: NoteOverview, o2: NoteOverview) -> Bool in
		return o1.time > o2.time
	}
	if !isAscending {
		return result.reversed()
	}
	return result
}

private func sortByDistance(isAscending: Bool, location: H3Cell, overviews: [NoteOverview])
	-> [NoteOverview]
{
	let result = overviews.sorted { (o1: NoteOverview, o2: NoteOverview) -> Bool in
		do {
			let o1LatLng = try cellToLatLng(cell: o1.location)
			let o2LatLng = try cellToLatLng(cell: o2.location)
			let locationLatLng = try cellToLatLng(cell: location)
			let o1Distance = Measurement(
				value: locationLatLng.distance(from: o1LatLng),
				unit: UnitLength.meters
			)
			let o2Distance = Measurement(
				value: locationLatLng.distance(from: o2LatLng),
				unit: UnitLength.meters
			)
			return o1Distance < o2Distance
		}
		catch {
			// effectively random
			return o1.time > o2.time
		}
	}
	if !isAscending {
		return result.reversed()
	}
	return result
}

/// Return the ordered list of overviews that are contained within the selected cell
func overviewsInCellOrdered(
	controller: RootController,
	overviews: [NoteOverview],
	selectedCell: H3Cell,
	userLocation: H3Cell?
)
	-> [NoteOverview]
{
	var overviewsInCell: [NoteOverview] = []
	let currentResolution = getResolution(cell: selectedCell)
	for o in overviews {
		// No location for this note
		if o.location == 0 {
			continue
		}
		else if o.location == selectedCell {
			overviewsInCell.append(o)
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
					overviewsInCell.append(o)
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
			// We know here that the note's location is a larger cell than the one we selected
			// we are therefore going to exclude it
			continue
		}
	}
	return overviewsInAreaOrdered(
		isAscending: controller.notes.store.sortAscending,
		overviews: overviewsInCell,
		selectedLocation: selectedCell,
		sort: controller.notes.store.sort,
		userLocation: userLocation
	)
}

private struct NoteList: View {
	var controller: RootController
	let overviewsOrdered: [NoteOverview]
	let selectedCell: H3Cell?
	let userLocation: H3Cell?

	init(
		controller: RootController,
		filterText: String,
		selectedCell: H3Cell?,
		userLocation: H3Cell?
	) {
		self.controller = controller
		self.selectedCell = selectedCell
		self.userLocation = userLocation
		guard let overviews = controller.notes.store.noteOverviews else {
			Logger.foreground.warning(
				"Got null noteOverviews in NoteList. This is programmer error."
			)
			self.overviewsOrdered = []
			return
		}
		let filteredOverviews = overviews.filter { overview in
			if filterText.isEmpty {
				return true
			}
			return overview.MatchesFilterText(filterText)
		}
		if selectedCell == nil {
			self.overviewsOrdered = overviewsInAreaOrdered(
				isAscending: controller.notes.store.sortAscending,
				overviews: filteredOverviews,
				selectedLocation: selectedCell,
				sort: controller.notes.store.sort,
				userLocation: userLocation
			)
		}
		else {
			self.overviewsOrdered = overviewsInCellOrdered(
				controller: controller,
				overviews: filteredOverviews,
				selectedCell: selectedCell!,
				userLocation: userLocation
			)
		}
	}

	var body: some View {
		if controller.notes.store.noteOverviews == nil {
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
		NavigationStack {
			NoteListView(
				controller: RootControllerPreview(
					notes: NotesControllerPreview(
						model: NotesStore.Preview.noNotes
					)
				),
				selectedCell: 0x88_2834_7053f_ffff,
				userLocation: RegionControllerPreview.userCell
			)
		}.previewDisplayName("no notes")
		NavigationStack {
			NoteListView(
				controller: RootControllerPreview(
					notes: NotesControllerPreview(
						model: NotesStore.Preview.someNotes
					)
				),
				selectedCell: nil,
				userLocation: RegionControllerPreview.userCell
			)
		}.previewDisplayName("base")
		NavigationStack {
			NoteListView(
				controller: RootControllerPreview(
					notes: NotesControllerPreview(
						model: NotesStore.Preview.notesWithIcons
					)
				),
				selectedCell: 0x88_2834_7053f_ffff,
				userLocation: RegionControllerPreview.userCell
			)
		}.previewDisplayName("icons")
		NavigationStack {
			NoteListRowContent(
				overview: noteOverviewPreview(
					[.AbundanceTrendUp, .SourceProbabilityIndicator]
				),
				userLocation: RegionControllerPreview.userCell
			)
		}.previewDisplayName("just icons")
	}
}
