/*
 * A map view that shows recent locations the user has been as well as their current location
 * Also allows the user to override their currently selected location
 */
import CH3
import H3
import MapKit
import SwiftUI

/*
 A map which shows an overlay of selected cells.
 */
struct MapViewBreadcrumb: View {
	let hexCount: Int = 100
	var onClickLatLng: ((CLLocationCoordinate2D) -> Void)? = nil
	var onClickCell: ((UInt64) -> Void)? = nil
	@Binding var overlayResolution: Int
	@Binding var region: MKCoordinateRegion
	@Binding var screenSize: CGSize
	var selectedCells: Set<CellSelection> = []
	var showsGrid: Bool = false
	var showsUserLocation: Bool = false
	var userCell: UInt64?

	private func onMapCameraChange(_ geometry: GeometryProxy, _ context: MapCameraUpdateContext)
	{
		/*location = CLLocation(
            latitude: context.region.center.latitude,
            longitude: context.region.center.longitude
        )*/
		region = context.region
		screenSize = geometry.size
		updateResolution(region)
	}

	private func updateResolution(_ newRegion: MKCoordinateRegion) {
		let hexCount = hexCount
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

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Map(
					initialPosition: MapCameraPosition.region(region),
					interactionModes: .all
				) {
					if showsUserLocation {
						UserAnnotation()
					}
					if userCell != nil {
						CellSelection(userCell!).asMapPolygon()
							.foregroundStyle(.red)
					}
					ForEach(Array(selectedCells)) { cell in
						cell.asMapPolygon().foregroundStyle(
							cell.foregroundStyle()
						)
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
					let gpsLocation = screenLocationToLatLng(
						location: screenLocation,
						region: region,
						screenSize: geometry.size
					)
					if onClickLatLng != nil {
						onClickLatLng!(gpsLocation)
					}
					do {
						let cell = try latLngToCell(
							latitude: gpsLocation.latitude,
							longitude: gpsLocation.longitude,
							resolution: overlayResolution
						)
						if onClickCell != nil {
							onClickCell!(cell)
						}
					}
					catch {
						print("Failed on tap: \(error)")
					}
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

struct MapViewBreadcrumb_Previews: PreviewProvider {
	@State static var overlayResolution: Int = 8
	@State static var region: MKCoordinateRegion = Initial.region
	@State static var screenSize: CGSize = .zero
	static var userCell: UInt64 = Initial.userCell
	static var previews: some View {
		MapViewBreadcrumb(
			overlayResolution: $overlayResolution,
			region: $region,
			screenSize: $screenSize,
			userCell: userCell
		)
	}
}
