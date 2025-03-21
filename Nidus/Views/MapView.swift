import CoreLocation
import MapKit
import SwiftUI

private let rectWidth: Double = 80

private struct MarkerData {
	let coordinate: CLLocationCoordinate2D
	let screenPoint: CGPoint

	var touchableRect: CGRect {
		.init(
			x: screenPoint.x - rectWidth / 2,
			y: screenPoint.y - rectWidth / 2,
			width: rectWidth,
			height: rectWidth
		)
	}
}

struct MapView: View {

	@Binding var coordinate: CLLocationCoordinate2D

	@State private var cameraPosition: MapCameraPosition
	@State private var coordinateInitial: CLLocationCoordinate2D
	@State private var modes: MapInteractionModes = [.all]
	@State private var isMarkerDragging = false
	//@State private var markerData: MarkerData?

	init(coordinate: Binding<CLLocationCoordinate2D>) {
		self._coordinate = coordinate
		self.coordinateInitial = coordinate.wrappedValue
		self.cameraPosition = MapCameraPosition.region(
			MKCoordinateRegion(
				center: coordinate.wrappedValue,
				span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
			)
		)
	}

	var body: some View {
		MapReader { proxy in
			Map(position: $cameraPosition, interactionModes: modes) {
				if coordinateInitial.latitude != coordinate.latitude
					|| coordinateInitial.longitude != coordinate.longitude
				{
					Marker("Current", coordinate: coordinate).tint(.red)
					Marker("Old", coordinate: coordinateInitial).tint(.gray)
				}
				else {
					Marker("New", coordinate: coordinateInitial).tint(.red)
				}
			}
			.mapControls {
				MapCompass()
				MapScaleView()
				MapUserLocationButton()
			}.mapStyle(
				MapStyle.standard(
					pointsOfInterest: PointOfInterestCategories.excludingAll
				)
			) /*
				.onTapGesture { screenCoordinate in
					self.markerData = proxy.markerData(
						screenCoordinate: screenCoordinate
					)
				}
				.highPriorityGesture(
					DragGesture(minimumDistance: 1)
						.onChanged { drag in
							guard let markerData else { return }
							if isMarkerDragging {

							}
							else if markerData.touchableRect.contains(
								drag.startLocation
							) {
								isMarkerDragging = true
								setMapInteraction(enabled: false)
							}
							else {
								return
							}

							self.markerData = proxy.markerData(
								screenCoordinate: drag.location
							)
						}
						.onEnded { drag in
							setMapInteraction(enabled: true)
							isMarkerDragging = false
						}
				)
				.onMapCameraChange {
					guard let markerData else { return }
					self.markerData = proxy.markerData(
						coordinate: markerData.coordinate
					)
				}*/
		}
	}

	private func setMapInteraction(enabled: Bool) {
		if enabled {
			modes = .all
		}
		else {
			modes = []
		}
	}
}

extension MapProxy {

	fileprivate func markerData(screenCoordinate: CGPoint)
		-> MarkerData?
	{
		guard let coordinate = convert(screenCoordinate, from: .local) else { return nil }
		return .init(coordinate: coordinate, screenPoint: screenCoordinate)
	}

	fileprivate func markerData(
		coordinate: CLLocationCoordinate2D
	) -> MarkerData? {
		guard let point = convert(coordinate, to: .local) else { return nil }
		return .init(coordinate: coordinate, screenPoint: point)
	}
}

struct MapView_Previews: PreviewProvider, View {
	@State var coordinate: CLLocationCoordinate2D = SampleLocations.park

	static var previews: some View {
		Self()
	}

	var body: some View {
		VStack {
			MapView(coordinate: $coordinate)
			Text("\(coordinate.latitude), \(coordinate.longitude)")
		}
	}
}
