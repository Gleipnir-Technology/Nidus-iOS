import MapKit
import OSLog
import SwiftUI

// The number of hexes we want to display at a minimum in the region. Used to calculate the H3 resolution to use
let MAX_HEX_COUNT: Int = 500

/*
 Controls information about our current region
 */
class RegionController {
	var store: RegionStore

	init(_ store: RegionStore) {
		self.store = store
	}

	@MainActor
	func addUserLocation(_ cells: [H3Cell]) {
		store.breadcrumb.userPreviousCells = store.breadcrumb.userPreviousCells.filter {
			key,
			val in
			Date.now.timeIntervalSince(val) < HISTORY_ENTRY_MAX_AGE
		}
		for c in cells {
			store.breadcrumb.userPreviousCells[c] = Date.now
		}
	}

	@MainActor
	func handleRegionChange(_ newRegion: MKCoordinateRegion, database: DatabaseController) {
		store.current = newRegion
		Task {
			let newResolution = try await updateResolution(newRegion)
			let noteCounts = await loadNoteCounts(
				database: database,
				region: newRegion,
				resolution: newResolution
			)
			Task { @MainActor in
				self.store.overlayResolution = newResolution
				self.store.noteCountsByType = noteCounts
			}
		}
	}

	private func loadNoteCounts(
		database: DatabaseController,
		region: MKCoordinateRegion,
		resolution: UInt
	) async
		-> [NoteType: [H3Cell: UInt]]
	{
		var results: [NoteType: [H3Cell: UInt]] = [:]
		TrackTime("load note counts") {
			do {
				let cells: Set<H3Cell> = try regionToCells(
					region,
					resolution: resolution,
					scale: 3.50
				)
				for noteType in NoteType.allCases {
					let summaries = try database.service
						.noteSummaries(noteType, cells)
					var cellToCount: [H3Cell: UInt] = [:]
					for summary in summaries {
						cellToCount[summary.cell] = summary.count
					}
					results[noteType] = cellToCount
				}
			}
			catch {
				CaptureError(error, "L")
			}
		}
		for noteType in NoteType.allCases {
			Logger.foreground.info(
				"\(results[noteType]?.count ?? 0) notes of type \(noteType.toString())"
			)
		}
		return results
	}

	@MainActor
	func onOverlaySelectionChanged(active: Set<MapOverlay>) {
		store.overlays = active
	}
	func updateResolution(_ newRegion: MKCoordinateRegion) async throws -> UInt {
		//if newRegion.span.latitudeDelta < 0.0005 || newRegion.span.longitudeDelta < 0.0005 {
		//return 15
		//}
		//else {
		return try regionToCellResolution(
			newRegion,
			maxCount: MAX_HEX_COUNT
		)
		//}
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

	@MainActor
	init() {
		let store = RegionStore()
		super.init(store)
	}
}
