import MapKit
import OSLog
import SwiftUI

private let SCALE_FACTOR = 3.0

struct CellSummary: Identifiable {
	var cell: H3Cell
	var id: H3Cell {
		cell
	}
	var count: UInt = 0
}

/// An overlay of flat h
final class HexOverlay: NSObject, MKOverlay {
	var cellBucketsByType: [NoteType: [UInt: [CellSummary]]]
	var cells: Set<H3Cell>
	var coordinate: CLLocationCoordinate2D
	let resolution: UInt
	let types: Set<MapOverlay>

	init(
		noteCountsByType: [NoteType: [H3Cell: UInt]],
		region: MKCoordinateRegion,
		resolution: UInt,
		types: Set<MapOverlay>
	) {
		self.coordinate = region.center
		self.cells = []
		self.resolution = resolution
		self.types = types

		self.cellBucketsByType = [:]
		for (cellType, sourceCells) in noteCountsByType {
			switch cellType {
			case .audio, .picture:
				if !types.contains(.Note) { continue }
			case .mosquitoSource:
				if !types.contains(.MosquitoSource) { continue }
			}

			self.cellBucketsByType[cellType] = [:]
			for (cell, count) in sourceCells {
				let bucket: UInt = min(count, 6)
				self.cellBucketsByType[cellType]![bucket, default: []].append(
					CellSummary(cell: cell, count: count)
				)
			}
		}
		super.init()
	}

	var boundingMapRect: MKMapRect {
		return .world
	}

	func intersects(_ mapRect: MKMapRect) -> Bool {
		return true
	}
}
