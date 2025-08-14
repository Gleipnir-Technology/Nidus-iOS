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

	// The callbacks to fire when the current region changes
	var currentChangeCallbacks: [(MKCoordinateRegion) -> Void] = []

	// The current region the user has selected in the map view
	var current: MKCoordinateRegion = Initial.region

	// The current H3 resolution we're using
	var resolution: H3Cell = 15

	// Callbacks to inform whenever we receive location data
	var locationChangeCallbacks: [([H3Cell]) -> Void] = []

	var locationDataManager: LocationDataManager = LocationDataManager()

	func handleRegionChange(_ region: MKCoordinateRegion) {
		current = region
		for c in currentChangeCallbacks {
			c(region)
		}
	}

	func onAppear() {
		locationChangeCallbacks.append(addUserLocation)
		locationDataManager.onLocationUpdated(handleLocationUpdated)
	}

	func onLocationUpdated(_ callback: @escaping (([H3Cell]) -> Void)) {
		locationChangeCallbacks.append(callback)
	}

	func onRegionChange(_ callback: @escaping (MKCoordinateRegion) -> Void) {
		currentChangeCallbacks.append(callback)
	}

	private func addUserLocation(_ cells: [H3Cell]) {
		breadcrumb.userPreviousCells = breadcrumb.userPreviousCells.filter { key, val in
			Date.now.timeIntervalSince(val) < HISTORY_ENTRY_MAX_AGE
		}
		for c in cells {
			breadcrumb.userPreviousCells[c] = Date.now
		}
	}

	private func handleLocationUpdated(_ locations: [CLLocation]) {
		do {
			let cells = try locations.map { l in
				let resolution = meterAccuracyToH3Resolution(l.horizontalAccuracy)
				return try latLngToCell(
					latLng: l.coordinate,
					resolution: resolution
				)
			}
			breadcrumb.userLocation = locations.last!
			breadcrumb.userCell = cells.last!
			for callback in locationChangeCallbacks {
				callback(cells)
			}
		}
		catch {
			Logger.background.error("Failed to calculate location cells: \(error)")
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
