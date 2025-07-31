import H3
import MapKit
import SwiftUI

/*
 * Represents an H3 cell that has been selected
 */
struct CellSelection: Equatable, Hashable, Identifiable {
	let cellID: UInt64
	var color: Color
	let id = UUID()

	init(_ cell: UInt64, color: Color = randomColor().opacity(0.3)) {
		self.cellID = cell
		self.color = color
	}

	static func == (lhs: CellSelection, rhs: CellSelection) -> Bool {
		return lhs.cellID == rhs.cellID
	}

	static func fromLatLng(_ latLng: CLLocationCoordinate2D, resolution: Int)
		-> CellSelection
	{
		do {
			return CellSelection(
				try latLngToCell(
					latitude: latLng.latitude,
					longitude: latLng.longitude,
					resolution: resolution
				)
			)
		}
		catch {
			return CellSelection(0)
		}
	}

	func asPolyline() -> MapPolyline {
		return MapPolyline(cellToPolyline(self))
	}

	func asMapPolygon() -> MapPolygon {
		return MapPolygon(cellToPolygon(self))
	}

	func foregroundStyle() -> Color {
		return color
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(cellID)
	}

	func withColor(_ color: Color) -> CellSelection {
		return CellSelection(cellID, color: color)
	}
}

func randomColor() -> Color {
	return Color(
		red: .random(in: 0...1),
		green: .random(in: 0...1),
		blue: .random(in: 0...1)
	)
}
