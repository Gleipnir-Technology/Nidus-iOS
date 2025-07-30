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
	@Binding var location: CLLocation
	var onClickLatLng: ((CLLocationCoordinate2D) -> Void)? = nil
	var onClickCell: ((UInt64) -> Void)? = nil
	var overlayResolution: Int? = nil
	@Binding var region: MKCoordinateRegion
	@Binding var screenSize: CGSize
	var selectedCells: Set<CellSelection> = []

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Map(
					initialPosition: MapCameraPosition.region(region),
					interactionModes: .all
				) {
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
				).onMapCameraChange(frequency: .continuous) { context in
					location = CLLocation(
						latitude: context.region.center.latitude,
						longitude: context.region.center.longitude
					)
					region = context.region
					screenSize = geometry.size
				}.onTapGesture { screenLocation in
					let gpsLocation = screenLocationToLatLng(
						location: screenLocation,
						region: region,
						screenSize: geometry.size
					)
					if onClickLatLng != nil {
						onClickLatLng!(gpsLocation)
					}
					if overlayResolution == nil {
						return
					}
					do {
						let cell = try latLngToCell(
							latitude: gpsLocation.latitude,
							longitude: gpsLocation.longitude,
							resolution: overlayResolution!
						)
						if onClickCell != nil {
							onClickCell!(cell)
						}
					}
					catch {
						print("Failed on tap: \(error)")
					}
				}

				if overlayResolution != nil {
					OverlayH3Grid(
						region: region,
						resolution: overlayResolution!,
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
			let b_deg = CLLocationCoordinate2D(
				latitude: b.lat,
				longitude: b.lng
			)
			coordinates.append(b_deg)
		}
		//print("polygon \(coordinates)")
		return MKPolygon(coordinates: coordinates, count: coordinates.count)
	}
	catch {
		return MKPolygon()
	}
}
