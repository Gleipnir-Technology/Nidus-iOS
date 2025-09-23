import MapKit
import OSLog
import SwiftUI

final class HexOverlayRenderer: MKOverlayRenderer {
	var fillColor: UIColor
	var lineWidth: CGFloat
	var strokeColor: UIColor

	override init(overlay: MKOverlay) {
		self.fillColor = UIColor.systemRed
		self.lineWidth = 10.0
		self.strokeColor = UIColor.systemBlue
		super.init(overlay: overlay)
	}

	override func draw(
		_ mapRect: MKMapRect,
		zoomScale: MKZoomScale,
		in context: CGContext
	) {
		guard let hexOverlay = overlay as? HexOverlay else {
			Logger.foreground.error("Unable to translate overlay to HexOverlay")
			return
		}

		for cellType in NoteType.allCases {
			var color = UIColor(colorForNoteType(cellType))
			let cellsForCurrentType = hexOverlay.cellBucketsByType[cellType] ?? [:]
			var maxCount: UInt = 0
			do {
				maxCount = try cellsForCurrentType.reduce<UInt>(
					0,
					{ result, pair in
						if pair.value.count == 0 {
							return result
						}
						return max(result, UInt(pair.key))
					}
				)
			}
			catch {
				Logger.foreground.error(
					"Failed to calculate max cell count: \(error)"
				)
			}
			context.setLineWidth(lineWidth)
			for (bucket, cells) in cellsForCurrentType {
				context.setFillColor(
					color.withAlphaComponent(
						alphaForBucket(bucket, maxCount)
					).cgColor
				)
				for cell in cells {
					context.beginPath()
					let polygon = cellToPolygon(cell.cell)
					var points: [CGPoint] = []
					for i in 0..<polygon.pointCount {
						let p = polygon.points()[i]
						points.append(CGPoint(x: p.x, y: p.y))
					}
					context.addLines(between: points)
					context.drawPath(using: .fill)
				}
			}
		}
	}

	func alphaForBucket(_ bucket: UInt, _ maxCount: UInt) -> CGFloat {
		let fractionOfMax = CGFloat(bucket) / CGFloat(maxCount)
		let maxAlpha: CGFloat = 0.6
		let floorAlhpa: CGFloat = 0.1
		return (maxAlpha * fractionOfMax) + floorAlhpa
	}
}
