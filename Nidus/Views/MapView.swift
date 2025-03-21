import CoreLocation
import MapKit
import SwiftUI

private let rectWidth: Double = 80

struct MapView: View {

	@Binding var coordinate: CLLocationCoordinate2D

	@State private var cameraPosition: MapCameraPosition
	@State private var coordinateInitial: CLLocationCoordinate2D
	@State private var modes: MapInteractionModes = [.all]
	@State private var isMarkerDragging = false

	init(coordinate: Binding<CLLocationCoordinate2D>) {
		self._coordinate = coordinate
		self.coordinateInitial = coordinate.wrappedValue
		self.cameraPosition = MapCameraPosition.region(
			MKCoordinateRegion(
				center: coordinate.wrappedValue,
				span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
			)
		)
	}

	var body: some View {
		MapReader { proxy in
			Map(position: $cameraPosition, interactionModes: modes) {
				if coordinateInitial.latitude != coordinate.latitude
					|| coordinateInitial.longitude != coordinate.longitude
				{
					Marker("Current", coordinate: coordinate).tint(.red)
					Marker("Old", coordinate: coordinateInitial).tint(.gray)
				}
				else {
					Marker("New", coordinate: coordinateInitial).tint(.red)
				}
			}
			.mapControls {
				MapCompass()
				MapScaleView()
				MapUserLocationButton()
			}.mapStyle(
				MapStyle.standard(
					pointsOfInterest: PointOfInterestCategories.excludingAll
				)
			)
			.onTapGesture { screenCoordinate in
				if let newCoordinate = proxy.convert(screenCoordinate, from: .local)
				{
					coordinate = newCoordinate
				}
			}
		}
	}

	private func setMapInteraction(enabled: Bool) {
		if enabled {
			modes = .all
		}
		else {
			modes = []
		}
	}
}

struct MapView_Previews: PreviewProvider, View {
	@State var coordinate: CLLocationCoordinate2D = SampleLocations.park.coordinate

	static var previews: some View {
		Self()
	}

	var body: some View {
		VStack {
			MapView(coordinate: $coordinate)
			Text("\(coordinate.latitude), \(coordinate.longitude)")
		}
	}
}
