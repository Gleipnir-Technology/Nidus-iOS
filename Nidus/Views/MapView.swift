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

	@State private var cameraPosition: MapCameraPosition = .automatic
	var coordinate: CLLocationCoordinate2D
	@State private var modes: MapInteractionModes = [.all]
	@State private var isMarkerDragging = false
	@State private var markerData: MarkerData?

	var body: some View {
		GeometryReader { geometryProxy in
			MapReader { mapProxy in
				Map(position: $cameraPosition, interactionModes: modes) {
					if let markerData {
						Marker("Start", coordinate: markerData.coordinate)
					}
				}
				.onTapGesture { screenCoordinate in
					self.markerData = mapProxy.markerData(
						screenCoordinate: screenCoordinate,
						geometryProxy: geometryProxy
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

							self.markerData = mapProxy.markerData(
								screenCoordinate: drag.location,
								geometryProxy: geometryProxy
							)
						}
						.onEnded { drag in
							setMapInteraction(enabled: true)
							isMarkerDragging = false
						}
				)
				.onMapCameraChange {
					guard let markerData else { return }
					self.markerData = mapProxy.markerData(
						coordinate: markerData.coordinate,
						geometryProxy: geometryProxy
					)
				}.onAppear {
					self.markerData = mapProxy.markerData(
						coordinate: coordinate,
						geometryProxy: geometryProxy
					)
				}
			}
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

	fileprivate func markerData(screenCoordinate: CGPoint, geometryProxy: GeometryProxy)
		-> MarkerData?
	{
		guard let coordinate = convert(screenCoordinate, from: .local) else { return nil }
		return .init(coordinate: coordinate, screenPoint: screenCoordinate)
	}

	fileprivate func markerData(
		coordinate: CLLocationCoordinate2D,
		geometryProxy: GeometryProxy
	) -> MarkerData? {
		guard let point = convert(coordinate, to: .local) else { return nil }
		return .init(coordinate: coordinate, screenPoint: point)
	}
}

#Preview("Broken", traits: .modifier(MockDataPreviewModifier())) {
	MapView(coordinate: Note.dog.location!.asCLLocationCoordinate2D())
}
