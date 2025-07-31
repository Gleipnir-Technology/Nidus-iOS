import MapKit
import SwiftUI

class Initial {
	static let location = CLLocation(
		latitude: 37.335190,
		longitude: -122.0088541
	)

	static let region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(
			latitude: location.coordinate.latitude,
			longitude: location.coordinate.longitude
		),
		span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
	)

	// near apple park, since that's where the maps like to default to.
	static let userCell: UInt64 = 0x8a2_8347_0532_ffff

	// near apple park again, since that's where preview location goes.
	static let userPreviousCells: [CellSelection] = [
		CellSelection(0x8a2_8347_05ad_ffff, color: Color.teal),
		CellSelection(0x8a2_8347_0536_7fff, color: Color.green),
		CellSelection(0x8a2_8347_0536_ffff, color: Color.blue),
	]
}
