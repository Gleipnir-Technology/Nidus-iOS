//
//  MapOverview.swift
//  Nidus
//
//  Created by Eli Ribble on 4/28/25.
//
import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct MapOverview: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Note.content) private var notes: [Note]
	@State private var geometrySize: CGSize = .zero

	var onNoteSelected: ((Note) -> Void)
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
		let view = geometry.frame(in: .global)

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
	private func findClosestNote(to coordinate: CLLocationCoordinate2D) -> Note? {
		notes.min { note, _ in
			let noteLocation = CLLocation(
				latitude: note.location.latitude,
				longitude: note.location.longitude
			)
			let tappedLocation = CLLocation(
				latitude: coordinate.latitude,
				longitude: coordinate.longitude
			)
			return noteLocation.distance(from: tappedLocation) < 100  // Within 100 meters
		}
	}
	var body: some View {
		GeometryReader { geometry in
			Map {
				ForEach(notes, id: \.id) { note in
					Marker(
						note.category.name,
						systemImage: note.category.icon,
						coordinate:
							note.location
							.asCLLocationCoordinate2D()
					).tint(
						.orange
					)
				}
			}.mapControls {
				MapCompass()
				MapScaleView()
				MapUserLocationButton()
			}.mapStyle(
				MapStyle.standard(
					pointsOfInterest: PointOfInterestCategories
						.excludingAll
				)
			).onTapGesture(coordinateSpace: .local) { tapLocation in
				geometrySize = geometry.size

				if let tappedCoordinate = convertTapToCoordinate(
					tapLocation: tapLocation,
					in: geometry
				) {
					if let closestNote = findClosestNote(
						to: tappedCoordinate
					) {
						onNoteSelected(closestNote)
					}
				}
			}
		}
	}
}

/*#Preview("1") {
	ModelContainerPreview(ModelContainer.sample) {
        MapOverview(onNoteSelected: {(note: Note) -> Void in print(note))

	}
}*/
