import CoreLocation
import MapKit
import SwiftUI

private let rectWidth: Double = 80

extension CLLocation {
	public static var visaliaCenter: CLLocation {
		.init(latitude: 36.326, longitude: -119.313191)
	}
}

struct LocationView: View {

	@Binding var location: CLLocation?

	@State private var cameraPosition: MapCameraPosition
	@State private var modes: MapInteractionModes = [.all]
	@State private var isMarkerDragging = false

	init(location: Binding<CLLocation?>) {
		self._location = location
		self.cameraPosition = MapCameraPosition.region(
			MKCoordinateRegion(
				center: location.wrappedValue?.coordinate
					?? CLLocationCoordinate2D(),
				span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
			)
		)
	}

	var body: some View {
		ZStack {
			Map(
				position: $cameraPosition,
				interactionModes: modes
			)
			.mapControls {
				MapCompass()
				MapScaleView()
				MapUserLocationButton()
			}.mapStyle(
				MapStyle.standard(
					pointsOfInterest: PointOfInterestCategories.excludingAll
				)
			)
			.onMapCameraChange(frequency: .onEnd) { context in
				location = CLLocation(
					latitude: context.region.center.latitude,
					longitude: context.region.center.longitude
				)
			}
			Image(systemName: "plus.viewfinder")
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

struct LocationView_Previews: PreviewProvider {
	@State static var location: CLLocation? = .visaliaCenter

	static var locationDescription: String {
		guard let location = location else {
			return "none"
		}
		return "\(location.coordinate.latitude), \(location.coordinate.longitude)"
	}
	static var previews: some View {
		VStack {
			LocationView(location: $location)
			Text(locationDescription)
		}
	}
}
