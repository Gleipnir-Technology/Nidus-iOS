/*
 * A map view that shows recent locations the user has been as well as their current location
 * Also allows the user to override their currently selected location
 */
import CH3
import H3
import MapKit
import OSLog
import SwiftUI

struct AnnotationSummary: Identifiable {
	var categories: Set<NoteType> = []
	var cell: H3Cell
	var coordinate: CLLocationCoordinate2D
	var count: Int = 0
	var id: H3Cell {
		cell
	}
	var weight: Double = 0
}
/*
 A map which shows an overlay of selected cells.
 */
struct MapViewBreadcrumb: View {
	let breadcrumbCells: [H3Cell]
	// The number of hexes we want to display at a minimum in the region. Used to calculate the H3 resolution to use
	let hexCount: Int = 75
	@State var currentRegion: MKCoordinateRegion = Initial.region
	let initialRegion: MKCoordinateRegion
	@State var notes: NotesController?
	// The current H3 resolution we're operating at
	@State var overlayResolution: Int = 8
	var region: RegionController?
	@State var screenSize: CGSize = .zero
	var showsGrid: Bool = false

	init(
		breadcrumbCells: [H3Cell],
		initialRegion: MKCoordinateRegion,
		notes: NotesController?,
		region: RegionController?,
		showsGrid: Bool = false
	) {
		self.breadcrumbCells = breadcrumbCells
		self.initialRegion = initialRegion
		self.notes = notes
		self.region = region
		self.showsGrid = showsGrid
	}

	private func annotationsByCell() -> [AnnotationSummary] {
		guard let notes = notes?.model.notes else {
			return []
		}
		var results: [H3Cell: AnnotationSummary] = [:]

		for note in notes.values {
			do {
				let cell = try scaleCell(
					note.location,
					to: overlayResolution
				)
				guard var summary: AnnotationSummary = results[cell] else {
					let summary = AnnotationSummary(
						categories: [note.category],
						cell: cell,
						coordinate: try cellToLatLng(cell: cell),
						count: 1
					)
					results[cell] = summary
					continue
				}
				summary.count += 1
				summary.categories.insert(note.category)
				results[cell] = summary
			}
			catch {
				Logger.foreground.error(
					"Failed to convert note location to H3 cell: \(error)"
				)
			}
		}
		// This is bad...but performant
		let maxCountByCell =
			results.max(by: { $0.value.count < $1.value.count })?.value.count ?? 0
		for cell in results.keys {
			results[cell]!.weight =
				Double(results[cell]!.count) / Double(maxCountByCell)
		}
		return results.map { $0.value }
	}

	private func onMapCameraChange(_ geometry: GeometryProxy, _ context: MapCameraUpdateContext)
	{
		currentRegion = context.region
		screenSize = geometry.size
		updateResolution(context.region)
		guard let region = self.region else {
			return
		}
		region.handleRegionChange(context.region)
	}

	private func onTapGesture(_ geometry: GeometryProxy, _ screenLocation: CGPoint) {
		guard let region = self.region else {
			return
		}
		let gpsLocation = screenLocationToLatLng(
			location: screenLocation,
			region: currentRegion,
			screenSize: geometry.size
		)
		Logger.foreground.info("Tapped on \(gpsLocation.latitude) \(gpsLocation.longitude)")
		do {
			let cell = try latLngToCell(
				latitude: gpsLocation.latitude,
				longitude: gpsLocation.longitude,
				resolution: overlayResolution
			)
			Logger.foreground.info("Tapped on cell \(String(cell, radix: 16))")
			region.breadcrumb.selectedCell = cell
		}
		catch {
			print("Failed on tap: \(error)")
		}
	}
	private func previousCellColor(_ index: Int) -> Color {
		Color.green.opacity(1.0 - Double(index) * 0.1)
	}

	private func updateResolution(_ newRegion: MKCoordinateRegion) {
		let hexCount = hexCount
		//Logger.background.info(
		//"New region: \(newRegion.span.latitudeDelta) \(newRegion.span.longitudeDelta)"
		//)
		if newRegion.span.latitudeDelta < 0.0005 || newRegion.span.longitudeDelta < 0.0005 {
			Logger.background.info("Forcing resolution 15")
			overlayResolution = 15
			return
		}

		Task.detached(priority: .background) {
			do {
				let start = Date.now
				let resolution = try regionToCellResolution(
					newRegion,
					count: hexCount
				)
				let end = Date.now
				Logger.foreground.info(
					"Took \(end.timeIntervalSince(start)) seconds to calculate resolution \(resolution)"
				)
				Task { @MainActor in
					overlayResolution = resolution
				}
			}
			catch {
				print("Unable to calculate resolution: \(error)")
				return
			}
		}
	}

	private func userPreviousCellsPolygons() -> [CellSelection] {
		var results: [CellSelection] = []
		for (i, cell) in breadcrumbCells.enumerated() {
			let color = previousCellColor(i)
			do {
				let scaledCell = try scaleCell(
					cell,
					to: overlayResolution
				)
				results.append(CellSelection(scaledCell, color: color))
			}
			catch {
				Logger.foreground.error("Failed to scale cell: \(error)")
			}
		}
		return results
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Map(
					initialPosition: MapCameraPosition.region(
						initialRegion
					),
					interactionModes: .all
				) {
					ForEach(annotationsByCell()) { summary in
						CellSelection(summary.cell).asMapPolygon()
							.foregroundStyle(
								Color.red.opacity(
									summary.weight
								)
							)
					}
					ForEach(userPreviousCellsPolygons()) { cell in
						cell.asMapPolyline().stroke(
							cell.color,
							lineWidth: 2
						)
					}
					if region?.breadcrumb.selectedCell != nil {
						CellSelection(region!.breadcrumb.selectedCell!)
							.asMapPolyline().stroke(
								.red,
								lineWidth: 3
							)
					}
					if region?.breadcrumb.userCell != nil {
						CellSelection(region!.breadcrumb.userCell!)
							.asMapPolyline().stroke(
								.blue,
								lineWidth: 2
							)
					}
					UserAnnotation()
				}
				.mapControls {
					MapCompass()
					MapScaleView()
					MapUserLocationButton()
				}.mapStyle(
					MapStyle.hybrid(
						pointsOfInterest: PointOfInterestCategories
							.excludingAll
					)
				).onMapCameraChange(frequency: .onEnd) { context in
					onMapCameraChange(geometry, context)
				}.onTapGesture { screenLocation in
					onTapGesture(geometry, screenLocation)
				}

				if showsGrid {
					OverlayH3Canvas(
						region: currentRegion,
						resolution: overlayResolution,
						screenSize: screenSize
					)
				}
			}
		}
	}
}

func cellToPolygon(_ cellSelection: CellSelection) -> MKPolygon {
	do {
		var coordinates: [CLLocationCoordinate2D] = []
		let boundary = try cellToBoundary(cell: cellSelection.cellID)
		for b in boundary {
			coordinates.append(b)
		}
		//print("polygon \(coordinates)")
		return MKPolygon(coordinates: coordinates, count: coordinates.count)
	}
	catch {
		return MKPolygon()
	}
}

func cellToPolyline(_ cellSelection: CellSelection) -> MKPolyline {
	do {
		var coordinates: [CLLocationCoordinate2D] = []
		let boundary = try cellToBoundary(cell: cellSelection.cellID)
		for b in boundary {
			coordinates.append(b)
		}
		// complete the circuit so a stroke goes all the way around the shape
		coordinates.append(coordinates[0])
		return MKPolyline(coordinates: coordinates, count: coordinates.count)
	}
	catch {
		return MKPolyline()
	}
}

struct MapViewBreadcrumb_Previews: PreviewProvider {
	@State static var notes: NotesController = NotesControllerPreview()
	@State static var region: RegionController = RegionControllerPreview()
	static var previews: some View {
		MapViewBreadcrumb(
			breadcrumbCells: [],
			initialRegion: Initial.region,
			notes: notes,
			region: region
		).previewDisplayName("current location only")
		MapViewBreadcrumb(
			breadcrumbCells: [],
			initialRegion: Initial.region,
			notes: notes,
			region: region
		).onAppear {
			region.breadcrumb.userPreviousCells =
				RegionControllerPreview.userPreviousCells
		}.previewDisplayName("current location and previous")
		MapViewBreadcrumb(
			breadcrumbCells: [],
			initialRegion: Initial.region,
			notes: notes,
			region: region
		).onAppear {
			notes.model = NotesModel.Preview.someNotes
			region.breadcrumb.selectedCell = RegionControllerPreview.selectedCell
			region.breadcrumb.userCell = RegionControllerPreview.userCell
			region.breadcrumb.userPreviousCells =
				RegionControllerPreview.userPreviousCells
		}.previewDisplayName("current location, selected location and previous")
	}
}
