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
	// The users previous locations as H3 indices. Index 0 is the most recent
	var userPreviousLocationH3: [UInt64] = []
	let userPreviousLocationsLimit: Int = 10

	private func addUserLocation(_ h3Cell: UInt64) {
		if userPreviousLocationH3.count == 0 {
			userPreviousLocationH3.append(h3Cell)
			return
		}
		if userPreviousLocationH3[0] == h3Cell {
			return
		}
		if userPreviousLocationH3.count >= userPreviousLocationsLimit {
			userPreviousLocationH3.removeLast()
		}
		userPreviousLocationH3.insert(h3Cell, at: 0)
	}

	private func onLocationUpdated(_ locations: [CLLocation]) {
		for location in locations {
			do {
				let h3Cell = try latLngToCell(
					latitude: location.coordinate.latitude,
					longitude: location.coordinate.longitude,
					resolution: resolution
				)
				addUserLocation(h3Cell)
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
