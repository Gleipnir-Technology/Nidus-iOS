/*
 * A map view that shows recent locations the user has been as well as their current location
 * Also allows the user to override their currently selected location
 */
import CH3
import H3
import MapKit
import OSLog
import SwiftUI

/// A map which shows an overlay of selected cells.
struct MapViewBreadcrumb: View {
	let breadcrumbCells: [H3Cell]
	// The number of hexes we want to display at a minimum in the region. Used to calculate the H3 resolution to use
	let hexCount: Int = 200
	@State var currentRegion: MKCoordinateRegion = Initial.region
	let initialRegion: MKCoordinateRegion
	// The current H3 resolution we're operating at
	@State var overlayResolution: UInt = 8
	@State var screenSize: CGSize = .zero
	var showsGrid: Bool = false

	init(
		breadcrumbCells: [H3Cell],
		initialRegion: MKCoordinateRegion,
		showsGrid: Bool = false
	) {
		self.breadcrumbCells = breadcrumbCells
		self.initialRegion = initialRegion
		self.showsGrid = showsGrid
	}

	private func onMapCameraChange(_ geometry: GeometryProxy, _ context: MapCameraUpdateContext)
	{
		currentRegion = context.region
		screenSize = geometry.size
		updateResolution(context.region)
	}

	private func previousCellColor(_ index: Int) -> Color {
		Color.green.opacity(1.0 - Double(index) * 0.1)
	}

	private func updateResolution(_ newRegion: MKCoordinateRegion) {
		let hexCount = hexCount
		//Logger.background.info(
		//"New region: \(newRegion.span.latitudeDelta) \(newRegion.span.longitudeDelta)"
		//)
		if newRegion.span.latitudeDelta < 0.0005 || newRegion.span.longitudeDelta < 0.0005 {
			//Logger.background.info("Forcing resolution 15")
			overlayResolution = 15
			return
		}

		Task.detached(priority: .background) {
			do {
				let resolution = try regionToCellResolution(
					newRegion,
					maxCount: hexCount
				)
				Task { @MainActor in
					overlayResolution = resolution
				}
			}
			catch {
				print("Unable to calculate resolution: \(error)")
				return
			}
		}
	}

	private func userPreviousCellsPolygons() -> [CellSelection] {
		var results: [CellSelection] = []
		for (i, cell) in breadcrumbCells.enumerated() {
			let color = previousCellColor(i)
			do {
				let scaledCell = try scaleCellLower(
					cell,
					downTo: overlayResolution
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
		GeometryReader { geometry in
			ZStack {
				Map(
					initialPosition: MapCameraPosition.region(
						initialRegion
					),
					interactionModes: .all
				) {
					ForEach(userPreviousCellsPolygons()) { cell in
						cell.asMapPolyline().stroke(
							cell.color,
							lineWidth: 2
						)
					}
					UserAnnotation()
				}
				.mapControls {
					MapCompass()
					MapScaleView()
					MapUserLocationButton()
				}.mapStyle(
					MapStyle.hybrid(
						pointsOfInterest: PointOfInterestCategories
							.excludingAll
					)
				).onMapCameraChange(frequency: .onEnd) { context in
					onMapCameraChange(geometry, context)
				}

				if showsGrid {
					OverlayH3Canvas(
						region: currentRegion,
						resolution: overlayResolution,
						screenSize: screenSize
					)
				}
			}
		}
	}
}

struct MapViewBreadcrumb_Previews: PreviewProvider {
	@State static var notes: NotesController = NotesControllerPreview()
	@State static var region: RegionController = RegionControllerPreview()
	static func onSelectCell(_ cell: H3Cell) {

	}
	static var previews: some View {
		MapViewBreadcrumb(
			breadcrumbCells: [],
			initialRegion: Initial.region
		).previewDisplayName("current location only")
	}
}
