/*
 * A map view that shows a single highlighted cell for a single location
 */
import CH3
import H3
import MapKit
import OSLog
import SwiftUI

/// A map which shows an overlay of selected cells.
struct MapCellView: View {
	let cell: H3Cell
	// The number of hexes we want to display at a minimum in the region. Used to calculate the H3 resolution to use
	let hexCount: Int = 200
	@State var currentRegion: MKCoordinateRegion = Initial.region
	// The current H3 resolution we're operating at
	@State var overlayResolution: UInt = 8
	@State var screenSize: CGSize = .zero
	var showsGrid: Bool = false

	init(
		cell: H3Cell,
		showsGrid: Bool = false
	) {
		self.cell = cell
		self.showsGrid = showsGrid
	}

	private func initialRegion() -> MKCoordinateRegion {
		do {
			let latLong = try cellToLatLng(cell: cell)
			return MKCoordinateRegion(
				center: latLong,
				span: MKCoordinateSpan(
					latitudeDelta: 0.001,
					longitudeDelta: 0.001
				)
			)
		}
		catch {
			Logger.foreground.error(
				"Failed to get lat/long from cell \(cell): \(error)"
			)
			return Initial.region
		}
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
			Logger.background.info("Forcing resolution 15")
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

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Map(
					initialPosition: MapCameraPosition.region(
						initialRegion()
					),
					interactionModes: .all
				) {
					CellSelection(cell)
						.asMapPolyline().stroke(
							.red,
							lineWidth: 3
						)
					UserAnnotation()
				}
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
#Preview {
	MapCellView(
		cell: 0x8f4_8eba_314c_0ac5
	)
}
