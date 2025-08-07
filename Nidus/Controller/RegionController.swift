import H3
import MapKit
import OSLog
import SwiftUI

/*
 Controls information about our current region
 */
@Observable
class RegionController {
	// Used for displaying the breadcrumb view
	var breadcrumb = BreadcrumbModel()

	// The current region the user has selected in the map view
	var current: MKCoordinateRegion = Initial.region

	// The current H3 resolution we're using
	var resolution: H3Cell = 15

	var locationDataManager: LocationDataManager = LocationDataManager()

	func onAppear() {
		locationDataManager.onLocationUpdated(onLocationUpdated)
	}

	func onRegionChange(_ region: MKCoordinateRegion) {
		current = region
	}

	private func addUserLocation(_ h3Cell: H3Cell) {
		if breadcrumb.userPreviousCells.keys.contains(h3Cell) {
			return
		}
		breadcrumb.userPreviousCells = breadcrumb.userPreviousCells.filter { key, val in
			Date.now.timeIntervalSince(val) < HISTORY_ENTRY_MAX_AGE
		}
		breadcrumb.userPreviousCells[h3Cell] = Date.now
	}

	private func onLocationUpdated(_ locations: [CLLocation]) {
		for location in locations {
			do {
				let h3Cell = try latLngToCell(
					latitude: location.coordinate.latitude,
					longitude: location.coordinate.longitude,
					resolution: HISTORY_RESOLUTION
				)
				addUserLocation(h3Cell)
				breadcrumb.userCell = h3Cell
				breadcrumb.userLocation = location
			}
			catch {
				Logger.background.warning(
					"Failed to get H3 cell for location \(location): \(error)"
				)
			}
		}
	}

}

class RegionControllerPreview: RegionController {

	static let selectedCell: H3Cell = 0x8a2_8347_053a_ffff

	// near apple park, since that's where the maps like to default to.
	static let userCell: H3Cell = 0x8a2_8347_0532_ffff

	// near apple park again, since that's where preview location goes.
	static let userPreviousCells: [H3Cell: Date] = [
		0x8a2_8347_05ad_ffff: Date.now,
		0x8a2_8347_0536_7fff: Date.now,
		0x8a2_8347_0536_ffff: Date.now,
	]
}
