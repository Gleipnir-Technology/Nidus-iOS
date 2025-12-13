import Foundation
import SwiftUI

/*
 Represents an arbitrary 2D polygon
 */
class Polygon: Identifiable {
	var points: [CGPoint]

	init(points: [CGPoint]) {
		self.points = points
	}

	func toPath() -> Path {
		var path = Path()
		for (i, point) in points.enumerated() {
			if i == 0 {
				path.move(to: point)
			}
			path.addLine(to: point)
		}
		path.closeSubpath()
		return path
	}
}
