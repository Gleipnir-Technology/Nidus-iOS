//
//  NoteMapView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/19/25.
//
import CoreLocation
import MapKit
import SwiftUI

struct PointOfInterest: Identifiable {
	let id = UUID()
	let name: String
	let latitude: Double
	let longitude: Double

	var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}
struct NoteMapView: View {
	@State private var region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 40.83834587046632, longitude: 14.25),
		span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
	)
	var userLocation: CLLocation?

	private let places = [
		//2.
		PointOfInterest(
			name: "Galeria Umberto I",
			latitude: 40.83859036140747,
			longitude: 14.24945566830365
		),
		PointOfInterest(name: "Castel dell'Ovo", latitude: 40.828206, longitude: 14.247549),
		PointOfInterest(
			name: "Piazza Dante",
			latitude: 40.848891382971985,
			longitude: 14.250055428532933
		),
	]

	var body: some View {
		Map {
			ForEach(places, id: \.id) { place in
				Marker(place.name, coordinate: place.coordinate).tint(.orange)
			}
			if let userLocation = userLocation {
				Marker("you", coordinate: userLocation.coordinate).tint(.blue)
			}
		}.mapStyle(
			MapStyle.standard(pointsOfInterest: PointOfInterestCategories.excludingAll)
		)
	}
}

#Preview("sample", traits: .modifier(MockDataPreviewModifier())) {
	NoteMapView(userLocation: CLLocation(latitude: 40.83834587046632, longitude: 14.25))
}
