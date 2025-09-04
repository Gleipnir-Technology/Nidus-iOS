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
			var color = UIColor.black
			switch cellType {
			case .audio, .picture:
				color = UIColor.blue
			case .mosquitoSource:
				color = UIColor.red
			}
			//context.setStrokeColor(UIColor.red.cgColor)
			context.setLineWidth(lineWidth)
			for (bucket, cells) in hexOverlay.cellBucketsByType[cellType] ?? [:] {
				context.setFillColor(
					color.withAlphaComponent(0.07 * CGFloat(bucket) + 0.1)
						.cgColor
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
}
