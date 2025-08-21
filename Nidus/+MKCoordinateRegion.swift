import MapKit

extension MKCoordinateRegion {
	var maxLongitude: CLLocationDegrees { center.longitude + span.longitudeDelta / 2 }
	var minLongitude: CLLocationDegrees { center.longitude - span.longitudeDelta / 2 }
	var maxLatitude: CLLocationDegrees { center.latitude + span.latitudeDelta / 2 }
	var minLatitude: CLLocationDegrees { center.latitude - span.latitudeDelta / 2 }
}

extension MKCoordinateRegion {
	public static var visalia: MKCoordinateRegion {
		.init(
			center: CLLocationCoordinate2D(
				latitude: 36.326,
				longitude: -119.313191
			),
			span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
		)
	}
}
