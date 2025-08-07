import MapKit
import SwiftUI

/*
 Controls information about our current region
 */
class RegionController: ObservableObject {
	// Used for displaying the breadcrumb view
	var breadcrumb = BreadcrumbModel()

	// The current region the user has selected in the map view
	var current: MKCoordinateRegion = Initial.region

	// The current H3 resolution we're using
	var resolution: H3Cell = 15

	init() {

	}

	func onRegionChange(_ region: MKCoordinateRegion) {
		current = region
	}
}

class RegionControllerPreview: RegionController {

	static let selectedCell: H3Cell = 0x8a2_8347_053a_ffff

	// near apple park, since that's where the maps like to default to.
	static let userCell: H3Cell = 0x8a2_8347_0532_ffff

	// near apple park again, since that's where preview location goes.
	static let userPreviousCells: [H3Cell] = [
		0x8a2_8347_05ad_ffff,
		0x8a2_8347_0536_7fff,
		0x8a2_8347_0536_ffff,
	]
}
