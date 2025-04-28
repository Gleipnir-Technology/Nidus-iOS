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
	var userLocation: CLLocation?
	var body: some View {
		ZStack(alignment: .trailing) {
			Map {
				ForEach(notes, id: \.id) { note in
					Marker(
						note.category.name,
						systemImage: note.category.icon,
						coordinate:
							note.location.asCLLocationCoordinate2D()
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

#Preview("1") {
	ModelContainerPreview(ModelContainer.sample) {
		MapOverview()
	}
}
