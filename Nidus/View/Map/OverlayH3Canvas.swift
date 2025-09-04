import H3
import MapKit
import SwiftUI

/*
 An overlay of H3 cell grid using a canvas
 */
struct OverlayH3Canvas: View {
	var fillColor: GraphicsContext.Shading = GraphicsContext.Shading.color(
		Color.black.opacity(0.1)
	)
	var lineColor: GraphicsContext.Shading = GraphicsContext.Shading.color(
		Color.black
	)
	let region: MKCoordinateRegion
	let resolution: UInt
	let screenSize: CGSize

	private func gridToPath(
		region: MKCoordinateRegion,
		resolution: UInt,
		screenSize: CGSize
	) -> Path {
		do {
			// Get the center cell for the region we are interested in
			let cell = try latLngToCell(
				latitude: region.center.latitude,
				longitude: region.center.longitude,
				resolution: Int(resolution)
			)
			// Determine the number of neighbors we'll need to get outside the region in each direction
			let extremes: [H3Cell] = [
				try latLngToCell(
					latitude: region.center.latitude - region.span.latitudeDelta
						/ 2,
					longitude: region.center.longitude - region.span
						.longitudeDelta
						/ 2,
					resolution: Int(resolution)
				),
				try latLngToCell(
					latitude: region.center.latitude - region.span.latitudeDelta
						/ 2,
					longitude: region.center.longitude + region.span
						.longitudeDelta
						/ 2,
					resolution: Int(resolution)
				),
				try latLngToCell(
					latitude: region.center.latitude + region.span.latitudeDelta
						/ 2,
					longitude: region.center.longitude - region.span
						.longitudeDelta
						/ 2,
					resolution: Int(resolution)
				),
				try latLngToCell(
					latitude: region.center.latitude + region.span.latitudeDelta
						/ 2,
					longitude: region.center.longitude + region.span
						.longitudeDelta
						/ 2,
					resolution: Int(resolution)
				),
			]
			var distances: [Int64] = [0, 0, 0, 0]
			for (i, e) in extremes.enumerated() {
				do {
					distances[i] = try gridDistance(
						origin: cell,
						destination: e
					)
				}
				catch {
					print(
						"Failed to get the grid distance for index \(i): origin \(String(cell, radix:16)) destination \(String(e, radix:16)): \(error)"
					)
				}
			}
			let maxDistance = distances.max() ?? 1
			var path: Path = Path()
			if maxDistance > 100 {
				print(
					"Refusing to flood the map grid with \(maxDistance) cells"
				)
				return path
			}
			let disk = try gridDisk(origin: cell, distance: Int(maxDistance))
			for d in disk {
				let shape = try cellToHexagon(
					cell: d,
					region: region,
					screenSize: screenSize
				)
				path.addPath(shape.toPath())
			}
			return path
		}
		catch {
			print("Failed to create the path: \(error)")
			return Path()
		}
	}

	var body: some View {
		if region.span.latitudeDelta < 0.000001
			|| region.span.longitudeDelta < 0.000001
		{
			ProgressView()
		}
		else {
			Canvas { context, size in
				let path = gridToPath(
					region: region,
					resolution: resolution,
					screenSize: screenSize
				)
				// Draw hexagon with stroke and fill
				context.stroke(
					path,
					with: lineColor,
					lineWidth: 1
				)

				context.fill(
					path,
					with: fillColor
				)
			}.allowsHitTesting(false)
		}
	}
}
