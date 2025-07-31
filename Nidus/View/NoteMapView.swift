//
//  NoteMapView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/19/25.
//
import CoreLocation
import MapKit
import SwiftData
import SwiftUI

/*
struct PointOfInterest: Identifiable {
	let id = UUID()
	let name: String
	let latitude: Double
	let longitude: Double

	var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}
*/

struct NoteMapView: View {
	private var notes: [any Note]

	var body: some View {
		ZStack(alignment: .trailing) {
			Map {
				ForEach(notes, id: \.id) { note in
					Marker(
						note.category.name,
						systemImage: note.category.icon,
						coordinate: note.coordinate
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
					pointsOfInterest: PointOfInterestCategories.excludingAll
				)
			)
		}
	}
}
