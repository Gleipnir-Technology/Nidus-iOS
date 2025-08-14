import MapKit
import SwiftUI

// The max age of location history we keep in seconds
let HISTORY_ENTRY_MAX_AGE: TimeInterval = 60 * 5

@Observable
class BreadcrumbModel {
	// The previous locations the user has been in
	var previousLocationH3s: [H3Cell] = []
	// The location the user has currently selected
	var selectedCell: H3Cell? = nil
	// The user's current position as Lat/Lng
	var userLocation: CLLocation? = nil
	// The users current position as an H3 hex
	var userCell: H3Cell? = nil
	// The users previous locations mapping an H3 index to the time they first entered that location
	var userPreviousCells: [H3Cell: Date] = [:]
}
