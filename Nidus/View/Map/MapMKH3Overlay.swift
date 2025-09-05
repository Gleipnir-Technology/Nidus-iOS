/// A map that can overlay H3 cells and do so rapidly
import H3
import MapKit
import OSLog
import SwiftUI

class MapWrapperViewCoordinator: NSObject, MKMapViewDelegate {
	var onMapCameraChange: ((MKCoordinateRegion) -> Void)
	var regionStore: RegionStore
	var resolution: UInt

	var geometryProxy: GeometryProxy?
	var mapView: MKMapView?
	var onSelectCell: (H3Cell) -> Void
	//let region: MKCoordinateRegion

	init(
		onMapCameraChange: @escaping ((MKCoordinateRegion) -> Void),
		regionStore: RegionStore,
		resolution: UInt
	) {
		self.geometryProxy = nil
		self.mapView = nil
		self.onSelectCell = { _ in }
		self.onMapCameraChange = onMapCameraChange
		self.regionStore = regionStore
		self.resolution = resolution
	}

	func addHexOverlay(_ mapView: MKMapView) {
		if regionStore.noteCountsByType == nil {
			Logger.foreground.info("No note counts, refusing to add hex overlay")
			return
		}
		let overlay = HexOverlay(
			noteCountsByType: regionStore.noteCountsByType!,
			region: mapView.region,
			resolution: resolution
		)
		mapView.addOverlay(overlay)
	}

	@objc
	func handleTap(_ sender: UITapGestureRecognizer) {
		if sender.state != .ended { return }
		guard let geometryProxy = geometryProxy else {
			Logger.foreground.error("geometryProxy is nil")
			return
		}

		let screenLocation = sender.location(in: mapView)
		let gpsLocation = screenLocationToLatLng(
			location: screenLocation,
			region: regionStore.current,
			screenSize: geometryProxy.size
		)
		Logger.foreground.info("Tapped on \(gpsLocation.latitude) \(gpsLocation.longitude)")
		do {
			let cell = try latLngToCell(
				latitude: gpsLocation.latitude,
				longitude: gpsLocation.longitude,
				resolution: Int(resolution)
			)
			Logger.foreground.info("Tapped on cell \(String(cell, radix: 16))")
			onSelectCell(cell)
		}
		catch {
			print("Failed on tap: \(error)")
		}
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)
		-> MKOverlayRenderer
	{
		if overlay is HexOverlay {
			guard let hexOverlay = overlay as? HexOverlay else {
				Logger.foreground.error("Unable to translate overlay to HexOverlay")
				return MKMultiPolygonRenderer(overlay: MKMultiPolygon([]))
			}
			//let renderer = MKMultiPolygonRenderer(overlay: hexOverlay.polygons)
			let renderer = HexOverlayRenderer(overlay: hexOverlay)
			renderer.strokeColor = UIColor.systemRed
			renderer.fillColor = UIColor.systemCyan.withAlphaComponent(0.3)
			renderer.lineWidth = 10
			return renderer
			//return HexOverlayRenderer(overlay: overlay)
		}
		else {
			print("Using default renderer")
			return MKOverlayRenderer(overlay: overlay)
		}
	}

	/// This is one of the `MKMapViewDelegate` method
	func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
		print(
			"map view finish loading at \(mapView.region.span.longitudeDelta),\(mapView.region.span.latitudeDelta)"
		)
		//mapView.setRegion($region.wrappedValue, animated: false)
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		// This calls WAY too often
		//onMapCameraChange(mapView.region)
	}
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		onMapCameraChange(mapView.region)
	}
	func prepareForTap(
		geometryProxy: GeometryProxy,
		mapView: MKMapView,
		onSelectCell: @escaping (H3Cell) -> Void
	) {
		self.geometryProxy = geometryProxy
		self.mapView = mapView
		self.onSelectCell = onSelectCell
	}
}

class MapViewTapHandler: NSObject {
	let geometryProxy: GeometryProxy
	let mapView: MKMapView
	var onSelectCell: (H3Cell) -> Void
	let region: MKCoordinateRegion
	let resolution: UInt

	init(
		geometryProxy: GeometryProxy,
		onSelectCell: @escaping (H3Cell) -> Void,
		mapView: MKMapView,
		region: MKCoordinateRegion,
		resolution: UInt
	) {
		self.geometryProxy = geometryProxy
		self.onSelectCell = onSelectCell
		self.mapView = mapView
		self.region = region
		self.resolution = resolution
	}

	@objc
	func handleTap(_ sender: UITapGestureRecognizer) {
	}

}

struct MapWrapperView: UIViewRepresentable {
	typealias UIViewType = MKMapView

	var geometry: GeometryProxy
	var initialRegion: MKCoordinateRegion
	var onMapCameraChange: ((MKCoordinateRegion) -> Void)
	var onSelectCell: (H3Cell) -> Void
	@Binding var region: MKCoordinateRegion
	var regionStore: RegionStore
	var resolution: UInt
	@State var screenSize: CGSize = .zero

	private func handleMapCameraChange(_ region: MKCoordinateRegion) {
		self.region = region
		screenSize = geometry.size
		onMapCameraChange(region)
	}

	func makeCoordinator() -> MapWrapperViewCoordinator {
		return MapWrapperViewCoordinator(
			onMapCameraChange: handleMapCameraChange,
			regionStore: regionStore,
			resolution: resolution
		)
	}

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()

		let gestureRecognizer = UITapGestureRecognizer(
			target: context.coordinator,
			action: #selector(context.coordinator.handleTap)
		)
		mapView.addGestureRecognizer(gestureRecognizer)
		mapView.delegate = context.coordinator
		mapView.isUserInteractionEnabled = true
		mapView.isPitchEnabled = true
		mapView.showsCompass = true
		mapView.showsScale = true
		mapView.showsUserLocation = true
		mapView.showsUserTrackingButton = true
		mapView.mapType = .hybrid
		mapView.removeAnnotations(mapView.annotations)
		let fits = mapView.regionThatFits(initialRegion)
		mapView.region = fits
		context.coordinator.prepareForTap(
			geometryProxy: geometry,
			mapView: mapView,
			onSelectCell: onSelectCell
		)
		return mapView
	}

	func updateUIView(_ uiView: MKMapView, context: Context) {
		context.coordinator.resolution = resolution
		uiView.removeOverlays(uiView.overlays)
		context.coordinator.addHexOverlay(uiView)
	}
}

struct MapMKH3Overlay: View {
	typealias MapCameraChangeHandler = (MKCoordinateRegion) -> Void
	typealias CellSelectionHandler = (H3Cell) -> Void

	var initialRegion: MKCoordinateRegion
	@State var handleMapCameraChange: MapCameraChangeHandler
	@State var handleSelectCell: CellSelectionHandler = { _ in }
	@State var region: MKCoordinateRegion
	var regionStore: RegionStore
	var resolution: UInt

	init(
		initialRegion: MKCoordinateRegion,
		onMapCameraChange: @escaping MapCameraChangeHandler,
		regionStore: RegionStore,
		resolution: UInt,
		onSelectCell: @escaping CellSelectionHandler
	) {
		self.initialRegion = initialRegion
		self.handleMapCameraChange = onMapCameraChange
		self.handleSelectCell = onSelectCell
		//self.handleMapCameraChange = { _ in }
		self._region = .init(wrappedValue: initialRegion)
		self.regionStore = regionStore
		self.resolution = resolution
	}

	func onMapCameraChange(_ handler: @escaping MapCameraChangeHandler) -> Self {
		self.handleMapCameraChange = handler
		return self
	}

	func onSelectCell(_ handler: @escaping CellSelectionHandler) -> Self {
		self.handleSelectCell = handler
		return self
	}

	var body: some View {
		GeometryReader { geometry in
			MapWrapperView(
				geometry: geometry,
				initialRegion: initialRegion,
				onMapCameraChange: handleMapCameraChange,
				onSelectCell: handleSelectCell,
				region: $region,
				regionStore: regionStore,
				resolution: resolution
			)
		}
	}
}
