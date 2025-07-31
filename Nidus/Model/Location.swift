import H3
import MapKit
import OSLog

// The resolution at which we store location history.
let HISTORY_RESOLUTION: Int = 15
// The max age of location history we keep in seconds
let HISTORY_ENTRY_MAX_AGE: TimeInterval = 60 * 5

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
	// The users previous locations mapping an H3 index to the time they first entered that location
	var userPreviousLocations: [UInt64: Date] = [:]

	private func addUserLocation(_ h3Cell: UInt64) {
		if userPreviousLocations.keys.contains(h3Cell) {
			return
		}
		userPreviousLocations = userPreviousLocations.filter { key, val in
			Date.now.timeIntervalSince(val) < HISTORY_ENTRY_MAX_AGE
		}
		userPreviousLocations[h3Cell] = Date.now
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
				userLocationH3 = h3Cell
				userLocation = location
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
