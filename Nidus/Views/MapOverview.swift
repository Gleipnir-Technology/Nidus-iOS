import ClusterMap
import ClusterMapSwiftUI
import CoreLocation
import MapKit
//
//  MapOverview.swift
//  Nidus
//
//  Created by Eli Ribble on 4/28/25.
//
import OSLog
import SwiftData
import SwiftUI

struct MapOverview: View {
	@State private var geometrySize: CGSize = .zero
	var model: NidusModel

	var onNoteSelected: ((any Note) -> Void)
	var userLocation: CLLocation?

	// Convert tap location to map coordinate
	private func convertTapToCoordinate(tapLocation: CGPoint, in geometry: GeometryProxy)
		-> CLLocationCoordinate2D?
	{
		guard let mapView = self.findMapView(in: geometry) else {
			print("Could not find MapView")
			return nil
		}
		let point = CGPoint(
			x: tapLocation.x,
			y: tapLocation.y
		)
		let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
		return coordinate
	}
	private func findMapView(in geometry: GeometryProxy) -> MKMapView? {
		//let view = geometry.frame(in: .global)

		func findMapView(in view: UIView) -> MKMapView? {
			if let mapView = view as? MKMapView {
				return mapView
			}

			for subview in view.subviews {
				if let mapView = findMapView(in: subview) {
					return mapView
				}
			}

			return nil
		}

		guard
			let windowScene = UIApplication.shared.connectedScenes.first
				as? UIWindowScene,
			let rootViewController = windowScene.windows.first?.rootViewController,
			let rootView = rootViewController.view
		else {
			return nil

		}
		return findMapView(in: rootView)
	}
	private func findClosestNote(to coordinate: CLLocationCoordinate2D) -> (any Note)? {
		/*
		notes.min { note, _ in
			let noteLocation = CLLocation(
				latitude: note.coordinate.latitude,
				longitude: note.coordinate.longitude
			)
			let tappedLocation = CLLocation(
				latitude: coordinate.latitude,
				longitude: coordinate.longitude
			)
			return noteLocation.distance(from: tappedLocation) < 100  // Within 100 meters
		}*/
		return nil
	}

	var body: some View {
		MapClustered(
			dataSource: model.cluster,
			onMapSizeChange: model.onMapSizeChange,
			onPositionChange: model.onMapPositionChange,
			region: model.currentRegion
		)
	}
}

/*#Preview("1") {
	ModelContainerPreview(ModelContainer.sample) {
        MapOverview(onNoteSelected: {(note: Note) -> Void in print(note))

	}
}*/
