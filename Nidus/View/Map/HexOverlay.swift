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

	init(
		noteCountsByType: [NoteType: [H3Cell: UInt]],
		region: MKCoordinateRegion,
		resolution: UInt
	) {
		self.coordinate = region.center
		self.cells = []
		self.resolution = resolution

		self.cellBucketsByType = [:]
		for (cellType, sourceCells) in noteCountsByType {
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
		//print("intersects?")
		return true
	}

	//var coordinate: CLLocationCoordinate2D {
	//return MKMapPoint(x: boundingMapRect.midX, y: boundingMapRect.midY).coordinate
	//}
	/*
	@MainActor
    private func countsForCells(_ categories: Set<NoteType>, cells: Set<H3Cell>) -> [AnnotationSummary] {
		var results: [AnnotationSummary] = []
		var cellToCount: [H3Cell: UInt] = [:]

		for noteType in categories {
			let countsForType = noteCountsByType[noteType] ?? [:]
			do {
				let regionCells = try regionToCells(
					controller.region.store.current,
					resolution: controller.region.store.overlayResolution,
					scale: 3.50
				)
				for cell in regionCells {
					// do stuff
					cellToCount[cell, default: 0] +=
						countsForType[cell, default: 0]
				}
			}
			catch {
				CaptureError(error, "calculating note overlay")
			}
		}
		for (cell, count) in cellToCount {
			if count > 0 {
				results.append(
					AnnotationSummary(cell: cell, count: count)
				)
			}
		}
		return results
	}

	///
	@MainActor
	private var overlayContentFS: some MapContent {
		let summaries: [AnnotationSummary] = noteOverlay([.mosquitoSource])
		let maxHex = 200
		let toRender =
			summaries.count > maxHex
			? summaries[..<maxHex] : summaries[..<summaries.count]
		Logger.foreground.info("Rendering \(toRender.count) FS polys")
		return ForEach(toRender) { summary in
			CellSelection(summary.cell).asMapPolygon()
				.foregroundStyle(
					Color.red.opacity(
						min(max(Double(summary.count) / 10.0, 0.2), 0.8)
					)
				)
		}
	}
   */
}
