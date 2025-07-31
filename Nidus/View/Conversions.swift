import H3
import MapKit
import OSLog

// Given a cell and a screen to fit it into, translate the cell's boundaries into the screen space
func cellToHexagon(cell: UInt64, region: MKCoordinateRegion, screenSize: CGSize) throws -> Shape {
	var points: [CGPoint] = []
	let boundary = try cellToBoundary(cell: cell)
	for b in boundary {
		points.append(
			gpsToPixels(
				coordinate: b,
				region: region,
				screenSize: screenSize
			)
		)
	}
	return Shape(points: points)
}

func cellToNeighbors(cell: UInt64, region: MKCoordinateRegion, screenSize: CGSize) throws -> [Shape]
{
	let ring = try gridRing(origin: cell, distance: 1)
	var neighbors: [Shape] = []
	for r in ring {
		neighbors.append(try cellToHexagon(cell: r, region: region, screenSize: screenSize))
	}
	return neighbors
}

// Given an H3 cell and a region of a map, determine if all the points of the cell are entirely within the region
func isCellInRegion(
	_ cell: UInt64,
	_ region: MKCoordinateRegion
) throws -> Bool {
	let boundary = try cellToBoundary(cell: cell)
	for b in boundary {
		if b.latitude > (region.center.latitude + region.span.latitudeDelta / 2)
			|| b.latitude
				< (region.center.latitude - region.span.latitudeDelta / 2)
			|| b.longitude
				> (region.center.longitude + region.span.longitudeDelta / 2)
			|| b.longitude
				< (region.center.longitude - region.span.longitudeDelta / 2)
		{
			return false
		}
	}
	return true
}

// Given a coordinate in Latitude/Longitude expressed in degrees and a region being shown in a screen
// calculate where the coordinate corresponds to a pixel in the screen space.
// In other words, given some view's screen size and the map region, find the pixel such that that pixel
// corresponds to the coordinates in the map.
func gpsToPixels(
	coordinate: CLLocationCoordinate2D,
	region: MKCoordinateRegion,
	screenSize: CGSize
) -> CGPoint {
	let distanceLat = region.center.latitude - coordinate.latitude
	let distanceLng = region.center.longitude - coordinate.longitude

	let pixelPerLat = screenSize.height / region.span.latitudeDelta
	let pixelPerLng = screenSize.width / region.span.longitudeDelta

	let xOffset = -1 * distanceLng * pixelPerLng
	let yOffset = distanceLat * pixelPerLat

	let xCoord = xOffset + (screenSize.width / 2)
	let yCoord = yOffset + (screenSize.height / 2)

	return CGPoint(x: xCoord, y: yCoord)
}

// Given a map region, find the largest cell centered on the region that fits within the region
func maxCellThatFits(_ region: MKCoordinateRegion) throws -> UInt64 {
	var resolution = 0
	var cell = try latLngToCell(
		latitude: region.center.latitude,
		longitude: region.center.longitude,
		resolution: resolution
	)
	while !(try isCellInRegion(cell, region)) {
		resolution += 1
		cell = try latLngToCell(
			latitude: region.center.latitude,
			longitude: region.center.longitude,
			resolution: resolution
		)
	}
	return cell
}

/*
 Given a region find the lowest resolution that provides at least count cells within the region
 */
func regionToCellResolution(_ region: MKCoordinateRegion, count: Int = 10) throws -> Int {
	var resolution: Int = 1
	let boundary = regionToCoordinates(region)
	while resolution < 16 {
		// Find the smallest cell that covers the region.
		let cells = try polygonToCells(boundary: boundary, resolution: resolution)
			.compactMap({ $0 != 0 ? $0 : nil })
		if cells.count > count {
			//let cellsAsHex = cells.map({ c in String(c, radix: 16) })
			//print("Cells: \(cellsAsHex))")
			Logger.background.info(
				"Choosing resolution \(resolution) to get \(cells.count)/\(count) cells"
			)
			return resolution
		}
		resolution += 1
	}
	return 0
}

/*
 Convert an MKCoordinateRegion to a square of CLLocationCoordinate2D
 */
func regionToCoordinates(_ region: MKCoordinateRegion) -> [CLLocationCoordinate2D] {
	return [
		CLLocationCoordinate2D(
			latitude: region.center.latitude - region.span.latitudeDelta / 2,
			longitude: region.center.longitude - region.span.longitudeDelta / 2
		),
		CLLocationCoordinate2D(
			latitude: region.center.latitude + region.span.latitudeDelta / 2,
			longitude: region.center.longitude - region.span.longitudeDelta / 2
		),
		CLLocationCoordinate2D(
			latitude: region.center.latitude - region.span.latitudeDelta / 2,
			longitude: region.center.longitude + region.span.longitudeDelta / 2
		),
		CLLocationCoordinate2D(
			latitude: region.center.latitude + region.span.latitudeDelta / 2,
			longitude: region.center.longitude + region.span.longitudeDelta / 2
		),
	]
}

/*
 Given a cell at a smaller resolution remap it to the larger resolution
 */
func scaleCell(_ cell: UInt64, to resolution: Int) throws -> UInt64 {
	let currentResolution = getResolution(cell: cell)
	if currentResolution == resolution {
		return cell
	}
	let latLng = try cellToLatLng(cell: cell)
	let scaled = try latLngToCell(latLng: latLng, resolution: resolution)
	return scaled
}

func screenLocationToLatLng(location: CGPoint, region: MKCoordinateRegion, screenSize: CGSize)
	-> CLLocationCoordinate2D
{
	let latPerPixel = region.span.latitudeDelta / screenSize.height
	let lngPerPixel = region.span.longitudeDelta / screenSize.width

	let distanceFromCenterX = location.x - (screenSize.width / 2)
	let distanceFromCenterY = location.y - (screenSize.height / 2)

	let latitude = region.center.self.latitude - (distanceFromCenterY * latPerPixel)
	let longitude = region.center.self.longitude + (distanceFromCenterX * lngPerPixel)

	return CLLocationCoordinate2D(
		latitude: latitude,
		longitude: longitude
	)
}
