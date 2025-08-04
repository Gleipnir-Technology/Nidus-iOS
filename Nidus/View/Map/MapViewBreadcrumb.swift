/*
 * A map view that shows recent locations the user has been as well as their current location
 * Also allows the user to override their currently selected location
 */
import CH3
import H3
import MapKit
import OSLog
import SwiftUI

/*
 A map which shows an overlay of selected cells.
 */
struct MapViewBreadcrumb: View {
	@State var controller: RegionController
	// The number of hexes we want to display at a minimum in the region. Used to calculate the H3 resolution to use
	let hexCount: Int = 75
	@State var screenSize: CGSize = .zero
	var showsGrid: Bool = false

	/*
    userPreviousCells: model.location
        .userPreviousLocations.sorted(by: {
            a,
            b in
            return a.value > b.value
        }).map({ element in element.key })
     */
	init(
		controller: RegionController,
		showsGrid: Bool = false
	) {
		self.controller = controller
		self.showsGrid = showsGrid
	}

	private func onMapCameraChange(_ geometry: GeometryProxy, _ context: MapCameraUpdateContext)
	{
		controller.current = context.region
		screenSize = geometry.size
		updateResolution(context.region)
	}

	private func onTapGesture(_ geometry: GeometryProxy, _ screenLocation: CGPoint) {
		let gpsLocation = screenLocationToLatLng(
			location: screenLocation,
			region: controller.current,
			screenSize: geometry.size
		)
		Logger.foreground.info("Tapped on \(gpsLocation.latitude) \(gpsLocation.longitude)")
		do {
			let cell = try latLngToCell(
				latitude: gpsLocation.latitude,
				longitude: gpsLocation.longitude,
				resolution: controller.breadcrumb.overlayResolution
			)
			Logger.foreground.info("Tapped on cell \(String(cell, radix: 16))")
			controller.breadcrumb.selectedCell = cell
		}
		catch {
			print("Failed on tap: \(error)")
		}
	}
	private func previousCellColor(_ index: Int) -> Color {
		Color.green.opacity(1.0 - Double(index) * 0.1)
	}

	private func updateResolution(_ newRegion: MKCoordinateRegion) {
		let hexCount = hexCount
		Logger.background.info(
			"New region: \(newRegion.span.latitudeDelta) \(newRegion.span.longitudeDelta)"
		)
		if newRegion.span.latitudeDelta < 0.0005 || newRegion.span.longitudeDelta < 0.0005 {
			Logger.background.info("Forcing resolution 15")
			controller.breadcrumb.overlayResolution = 15
			return
		}

		Task.detached(priority: .background) {
			do {
				let resolution = try regionToCellResolution(
					newRegion,
					count: hexCount
				)
				Task { @MainActor in
					controller.breadcrumb.overlayResolution = resolution
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
		for (i, cell) in controller.breadcrumb.userPreviousCells.enumerated() {
			let color = previousCellColor(i)
			do {
				let scaledCell = try scaleCell(
					cell,
					to: controller.breadcrumb.overlayResolution
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
						controller.current
					),
					interactionModes: .all
				) {
					ForEach(userPreviousCellsPolygons()) { cell in
						cell.asPolyline().stroke(cell.color, lineWidth: 2)
					}
					if controller.breadcrumb.selectedCell != nil {
						CellSelection(controller.breadcrumb.selectedCell!)
							.asPolyline().stroke(
								.red,
								lineWidth: 3
							)
					}
					if controller.breadcrumb.userCell != nil {
						CellSelection(controller.breadcrumb.userCell!)
							.asPolyline().stroke(
								.blue,
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
					MapStyle.standard(
						pointsOfInterest: PointOfInterestCategories
							.excludingAll
					)
				).onMapCameraChange(frequency: .onEnd) { context in
					onMapCameraChange(geometry, context)
				}.onTapGesture { screenLocation in
					onTapGesture(geometry, screenLocation)
				}

				if showsGrid {
					OverlayH3Canvas(
						region: controller.current,
						resolution: controller.breadcrumb.overlayResolution,
						screenSize: screenSize
					)
				}
			}
		}
	}
}

func cellToPolygon(_ cellSelection: CellSelection) -> MKPolygon {
	do {
		var coordinates: [CLLocationCoordinate2D] = []
		let boundary = try cellToBoundary(cell: cellSelection.cellID)
		for b in boundary {
			coordinates.append(b)
		}
		//print("polygon \(coordinates)")
		return MKPolygon(coordinates: coordinates, count: coordinates.count)
	}
	catch {
		return MKPolygon()
	}
}

func cellToPolyline(_ cellSelection: CellSelection) -> MKPolyline {
	do {
		var coordinates: [CLLocationCoordinate2D] = []
		let boundary = try cellToBoundary(cell: cellSelection.cellID)
		for b in boundary {
			coordinates.append(b)
		}
		// complete the circuit so a stroke goes all the way around the shape
		coordinates.append(coordinates[0])
		return MKPolyline(coordinates: coordinates, count: coordinates.count)
	}
	catch {
		return MKPolyline()
	}
}

struct MapViewBreadcrumb_Previews: PreviewProvider {
	@State static var controller: RegionController = RegionControllerPreview()
	static var previews: some View {
		MapViewBreadcrumb(
			controller: controller
		).previewDisplayName("current location only")
		MapViewBreadcrumb(
			controller: controller
		).onAppear {
			controller.breadcrumb.userPreviousCells =
				RegionControllerPreview.userPreviousCells
		}.previewDisplayName("current location and previous")
		MapViewBreadcrumb(
			controller: controller
		).onAppear {
			controller.breadcrumb.selectedCell = RegionControllerPreview.selectedCell
			controller.breadcrumb.userCell = RegionControllerPreview.userCell
			controller.breadcrumb.userPreviousCells =
				RegionControllerPreview.userPreviousCells
		}.previewDisplayName("current location, selected location and previous")
	}
}
