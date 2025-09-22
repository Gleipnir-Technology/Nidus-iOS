import MapKit
import SwiftUI

// The max age of location history we keep in seconds
let HISTORY_ENTRY_MAX_AGE: TimeInterval = 60 * 5

@MainActor
@Observable
class BreadcrumbStore {
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

@MainActor
@Observable
class RegionStore {
	var breadcrumb: BreadcrumbStore = BreadcrumbStore()

	// The current region the user has selected in the map view
	var current: MKCoordinateRegion = Initial.region

	// The aggregated note information. Maps a note type to a cell to a count of
	// notes of that type in the cell
	var noteCountsByType: [NoteType: [H3Cell: UInt]]?

	// The current H3 resolution we're operating at
	var overlayResolution: UInt = 8

	// The current overlays we're showing
	var overlays: Set<MapOverlay> = []
}
