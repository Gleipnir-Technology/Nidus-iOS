import MapKit
import SwiftUI

class Initial {
	static let location = CLLocation(
		latitude: 37.779205,
		longitude: -122.419344
	)

	static let region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(
			latitude: location.coordinate.latitude,
			longitude: location.coordinate.longitude
		),
		span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
	)
}
