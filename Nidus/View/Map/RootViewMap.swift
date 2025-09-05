import CH3
import H3
import MapKit
import OSLog
import SwiftUI

/// The map on the root view which has a bunch of informatio it can display
/// Shows recent locations the user has been as well as their current location
/// Also allows the user to override their currently selected location
struct RootViewMap: View {
	let breadcrumbCells: [H3Cell]
	@State var currentRegion: MKCoordinateRegion = Initial.region
	let initialRegion: MKCoordinateRegion
	// The callback when a cell is selected
	var onSelectCell: (H3Cell) -> Void
	var controller: RootController
	var showsGrid: Bool = false

	init(
		breadcrumbCells: [H3Cell],
		controller: RootController,
		initialRegion: MKCoordinateRegion,
		onSelectCell: @escaping (H3Cell) -> Void,
		showsGrid: Bool = false
	) {
		self.breadcrumbCells = breadcrumbCells
		self.initialRegion = initialRegion
		self.onSelectCell = onSelectCell
		self.controller = controller
		self.showsGrid = showsGrid
	}

	private func previousCellColor(_ index: Int) -> Color {
		Color.green.opacity(1.0 - Double(index) * 0.1)
	}

	private func userPreviousCellsPolygons() -> [CellSelection] {
		var results: [CellSelection] = []
		for (i, cell) in breadcrumbCells.enumerated() {
			let color = previousCellColor(i)
			do {
				let scaledCell = try scaleCellLower(
					cell,
					downTo: controller.region.store.overlayResolution
				)
				results.append(CellSelection(scaledCell, color: color))
			}
			catch {
				Logger.foreground.error("Failed to scale cell: \(error)")
			}
		}
		return results
	}

	var body: some View {
		ZStack {
			MapMKH3Overlay(
				initialRegion: initialRegion,
				onMapCameraChange: { region in
					controller.handleRegionChange(region)
				},
				regionStore: controller.region.store,
				resolution: controller.region.store.overlayResolution,
				onSelectCell: { cell in
					onSelectCell(cell)
				}
			)
			/*
				Map(
				) {
					ForEach(userPreviousCellsPolygons()) { cell in
						cell.asMapPolyline().stroke(
							cell.color,
							lineWidth: 2
						)
					}
					if controller.region.store.breadcrumb.selectedCell != nil {
						CellSelection(
							controller.region.store.breadcrumb
								.selectedCell!
						)
						.asMapPolyline().stroke(
							.red,
							lineWidth: 3
						)
					}
					if controller.region.store.breadcrumb.userCell != nil {
						CellSelection(
							controller.region.store.breadcrumb.userCell!
						)
						.asMapPolyline().stroke(
							.blue,
							lineWidth: 2
						)
					}
				}.onTapGesture { screenLocation in
					onTapGesture(geometry, screenLocation)
				}

				if showsGrid {
					OverlayH3Canvas(
						region: currentRegion,
                        resolution: controller.region.store.overlayResolution,
						screenSize: screenSize
					)
				}
                     */
		}
	}
}

struct RootViewMap_Previews: PreviewProvider {
	@State static var notes: NotesController = NotesControllerPreview()
	@State static var controller: RootController = RootControllerPreview()
	static func onSelectCell(_ cell: H3Cell) {

	}
	static var previews: some View {
		RootViewMap(
			breadcrumbCells: [],
			controller: controller,
			initialRegion: Initial.region,
			onSelectCell: onSelectCell
		).previewDisplayName("current location only")
		RootViewMap(
			breadcrumbCells: [],
			controller: controller,
			initialRegion: Initial.region,
			onSelectCell: onSelectCell
		).onAppear {
			controller.region.store.breadcrumb.userPreviousCells =
				RegionControllerPreview.userPreviousCells
		}.previewDisplayName("current location and previous")
		RootViewMap(
			breadcrumbCells: [],
			controller: controller,
			initialRegion: Initial.region,
			onSelectCell: onSelectCell
		).onAppear {
			notes.model = NotesModel.Preview.someNotes
			controller.region.store.breadcrumb.selectedCell =
				RegionControllerPreview.selectedCell
			controller.region.store.breadcrumb.userCell =
				RegionControllerPreview.userCell
			controller.region.store.breadcrumb.userPreviousCells =
				RegionControllerPreview.userPreviousCells
		}.previewDisplayName("current location, selected location and previous")
	}
}
