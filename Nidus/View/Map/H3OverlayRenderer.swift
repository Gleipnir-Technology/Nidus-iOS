import MapKit
import OSLog
import SwiftUI

class H3Overlay: NSObject, MKOverlay {
	let elements: [H3OverlayElement]
	init(_ elements: [H3OverlayElement]) {
		self.elements = elements
	}

	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: 0, longitude: 0)
	}

	var boundingMapRect: MKMapRect {
		return .world
	}
}

final class H3OverlayRenderer: MKOverlayRenderer {
	override init(overlay: MKOverlay) {
		super.init(overlay: overlay)
	}

	override func draw(
		_ mapRect: MKMapRect,
		zoomScale: MKZoomScale,
		in context: CGContext
	) {
		guard let hexOverlay = overlay as? H3Overlay else {
			Logger.foreground.error("Unable to translate overlay to HexOverlay")
			return
		}

		for element in hexOverlay.elements {
			context.setLineWidth(element.lineWidth)
			if element.fillColor != nil {
				context.setFillColor(element.fillColor!.cgColor)
			}
			context.setStrokeColor(element.outlineColor.cgColor)
			context.beginPath()
			let polygon = cellToPolygon(element.cell)
			var points: [CGPoint] = []
			for i in 0..<polygon.pointCount {
				let p = polygon.points()[i]
				points.append(CGPoint(x: p.x, y: p.y))
			}
			context.addLines(between: points)
			if element.fillColor != nil {
				context.drawPath(using: .fill)
			}
			else {
				context.drawPath(using: .stroke)
			}
		}
	}
}
