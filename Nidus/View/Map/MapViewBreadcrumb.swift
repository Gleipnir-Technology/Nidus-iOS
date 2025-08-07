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
	// The number of hexes we want to display at a minimum in the region. Used to calculate the H3 resolution to use
	let hexCount: Int = 75
	@State var notes: NotesController
	@State var region: RegionController
	@State var screenSize: CGSize = .zero
	var showsGrid: Bool = false

	init(
		notes: NotesController,
		region: RegionController,
		showsGrid: Bool = false
	) {
		self.notes = notes
		self.region = region
		self.showsGrid = showsGrid
	}

	private func onMapCameraChange(_ geometry: GeometryProxy, _ context: MapCameraUpdateContext)
	{
		region.handleRegionChange(context.region)
		screenSize = geometry.size
		updateResolution(context.region)
	}

	private func onTapGesture(_ geometry: GeometryProxy, _ screenLocation: CGPoint) {
		let gpsLocation = screenLocationToLatLng(
			location: screenLocation,
			region: region.current,
			screenSize: geometry.size
		)
		Logger.foreground.info("Tapped on \(gpsLocation.latitude) \(gpsLocation.longitude)")
		do {
			let cell = try latLngToCell(
				latitude: gpsLocation.latitude,
				longitude: gpsLocation.longitude,
				resolution: region.breadcrumb.overlayResolution
			)
			Logger.foreground.info("Tapped on cell \(String(cell, radix: 16))")
			region.breadcrumb.selectedCell = cell
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
		//Logger.background.info(
		//"New region: \(newRegion.span.latitudeDelta) \(newRegion.span.longitudeDelta)"
		//)
		if newRegion.span.latitudeDelta < 0.0005 || newRegion.span.longitudeDelta < 0.0005 {
			Logger.background.info("Forcing resolution 15")
			region.breadcrumb.overlayResolution = 15
			return
		}

		Task.detached(priority: .background) {
			do {
				let resolution = try regionToCellResolution(
					newRegion,
					count: hexCount
				)
				Task { @MainActor in
					region.breadcrumb.overlayResolution = resolution
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
		for (i, element) in region.breadcrumb.userPreviousCells.enumerated() {
			let color = previousCellColor(i)
			do {
				let scaledCell = try scaleCell(
					element.key,
					to: region.breadcrumb.overlayResolution
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
						region.current
					),
					interactionModes: .all
				) {
					ForEach(notes.model.mapAnnotations) { annotation in
						Annotation(
							annotation.text,
							coordinate: annotation.coordinate
						) {
							ZStack {
								RoundedRectangle(cornerRadius: 5)
									.fill(.background)
								RoundedRectangle(cornerRadius: 5)
									.stroke(
										.secondary,
										lineWidth: 5
									)
								Image(systemName: annotation.icon)
							}
						}
					}
					ForEach(userPreviousCellsPolygons()) { cell in
						cell.asPolyline().stroke(cell.color, lineWidth: 2)
					}
					if region.breadcrumb.selectedCell != nil {
						CellSelection(region.breadcrumb.selectedCell!)
							.asPolyline().stroke(
								.red,
								lineWidth: 3
							)
					}
					if region.breadcrumb.userCell != nil {
						CellSelection(region.breadcrumb.userCell!)
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
					MapStyle.hybrid(
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
						region: region.current,
						resolution: region.breadcrumb.overlayResolution,
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
	@State static var notes: NotesController = NotesControllerPreview()
	@State static var region: RegionController = RegionControllerPreview()
	static var previews: some View {
		MapViewBreadcrumb(
			notes: notes,
			region: region
		).previewDisplayName("current location only")
		MapViewBreadcrumb(
			notes: notes,
			region: region
		).onAppear {
			region.breadcrumb.userPreviousCells =
				RegionControllerPreview.userPreviousCells
		}.previewDisplayName("current location and previous")
		MapViewBreadcrumb(
			notes: notes,
			region: region
		).onAppear {
			notes.model = NotesModel.Preview.someNotes
			region.breadcrumb.selectedCell = RegionControllerPreview.selectedCell
			region.breadcrumb.userCell = RegionControllerPreview.userCell
			region.breadcrumb.userPreviousCells =
				RegionControllerPreview.userPreviousCells
		}.previewDisplayName("current location, selected location and previous")
	}
}
