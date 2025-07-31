import H3
import MapKit
import OSLog

/*
 Holds information about the user's location
 */
class ModelLocation {
	// The previous locations the user has been in
	var previousLocationH3s: [UInt64] = []
	// The current H3 resolution we're operating at
	var resolution: Int = 8
	// The location the user has currently selected
	var selectedLocationH3: UInt64? = nil
	// The user's current position as Lat/Lng
	var userLocation: CLLocation? = nil
	// The users current position as an H3 hex
	var userLocationH3: UInt64? = nil

	func onLocationUpdated(_ locations: [CLLocation]) {
		for location in locations {
			do {
				let h3Cell = try latLngToCell(
					latitude: location.coordinate.latitude,
					longitude: location.coordinate.longitude,
					resolution: resolution
				)
			}
			catch {
				Logger.background.warning(
					"Failed to get H3 cell for location \(location): \(error)"
				)
			}
		}
	}

	func subscribe(_ locationDataManager: LocationDataManager) {
		locationDataManager.onLocationUpdated(onLocationUpdated)
	}
}
