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
	let hexCount: Int = 75
	var onClickLatLng: ((CLLocationCoordinate2D) -> Void)? = nil
	var onClickCell: ((UInt64) -> Void)? = nil
	@Binding var overlayResolution: Int
	@Binding var region: MKCoordinateRegion
	@Binding var screenSize: CGSize
	@Binding var selectedCell: UInt64?
	var showsGrid: Bool = false
	var showsUserLocation: Bool = false
	var userCell: UInt64?
	var userPreviousCells: [UInt64]

	init(
		onClickLatLng: ((CLLocationCoordinate2D) -> Void)? = nil,
		onClickCell: ((UInt64) -> Void)? = nil,
		overlayResolution: Binding<Int>,
		region: Binding<MKCoordinateRegion>,
		screenSize: Binding<CGSize>,
		selectedCell: Binding<UInt64?>,
		showsGrid: Bool = false,
		showsUserLocation: Bool = false,
		userCell: UInt64? = nil,
		userPreviousCells: [UInt64]
	) {
		self.onClickLatLng = onClickLatLng
		self.onClickCell = onClickCell
		self._overlayResolution = overlayResolution
		self._region = region
		self._screenSize = screenSize
		self._selectedCell = selectedCell
		self.showsGrid = showsGrid
		self.showsUserLocation = showsUserLocation
		self.userCell = userCell
		self.userPreviousCells = userPreviousCells
	}

	private func onMapCameraChange(_ geometry: GeometryProxy, _ context: MapCameraUpdateContext)
	{
		region = context.region
		screenSize = geometry.size
		updateResolution(region)
	}

	private func onTapGesture(_ geometry: GeometryProxy, _ screenLocation: CGPoint) {
		let gpsLocation = screenLocationToLatLng(
			location: screenLocation,
			region: region,
			screenSize: geometry.size
		)
		Logger.foreground.info("Tapped on \(gpsLocation.latitude) \(gpsLocation.longitude)")
		if onClickLatLng != nil {
			onClickLatLng!(gpsLocation)
		}
		do {
			let cell = try latLngToCell(
				latitude: gpsLocation.latitude,
				longitude: gpsLocation.longitude,
				resolution: overlayResolution
			)
			Logger.foreground.info("Tapped on cell \(String(cell, radix: 16))")
			if onClickCell != nil {
				onClickCell!(cell)
			}
			selectedCell = cell
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
			self.overlayResolution = 15
			return
		}

		Task.detached(priority: .background) {
			do {
				let resolution = try regionToCellResolution(
					newRegion,
					count: hexCount
				)
				Task { @MainActor in
					self.overlayResolution = resolution
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
		for (i, cell) in userPreviousCells.enumerated() {
			let color = previousCellColor(i)
			do {
				let scaledCell = try scaleCell(cell, to: overlayResolution)
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
					initialPosition: MapCameraPosition.region(region),
					interactionModes: .all
				) {
					ForEach(userPreviousCellsPolygons()) { cell in
						cell.asPolyline().stroke(cell.color, lineWidth: 2)
					}
					if selectedCell != nil {
						CellSelection(selectedCell!).asPolyline().stroke(
							.red,
							lineWidth: 3
						)
					}
					if userCell != nil {
						CellSelection(userCell!).asPolyline().stroke(
							.blue,
							lineWidth: 2
						)
					}
					if showsUserLocation {
						UserAnnotation()
					}
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
						region: region,
						resolution: overlayResolution,
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
	@State static var overlayResolution: Int = 8
	@State static var region: MKCoordinateRegion = Initial.region
	@State static var screenSize: CGSize = .zero
	@State static var selectedCell: UInt64? = nil
	static var userCell: UInt64 = Initial.userCell
	static var userPreviousCells: [UInt64] = Initial.userPreviousCells
	static var previews: some View {
		MapViewBreadcrumb(
			overlayResolution: $overlayResolution,
			region: $region,
			screenSize: $screenSize,
			selectedCell: $selectedCell,
			userCell: userCell,
			userPreviousCells: []
		).previewDisplayName("current location only")
		MapViewBreadcrumb(
			overlayResolution: $overlayResolution,
			region: $region,
			screenSize: $screenSize,
			selectedCell: $selectedCell,
			userCell: userCell,
			userPreviousCells: userPreviousCells
		).previewDisplayName("current location and previous")
		MapViewBreadcrumb(
			overlayResolution: $overlayResolution,
			region: $region,
			screenSize: $screenSize,
			selectedCell: $selectedCell,
			userCell: userCell,
			userPreviousCells: userPreviousCells
		).onAppear {
			selectedCell = Initial.selectedCell
		}.previewDisplayName("current location, selected location and previous")
	}
}
