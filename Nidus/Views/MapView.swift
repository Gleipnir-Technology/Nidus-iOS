//
//  MapView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//

import MapKit
import SwiftUI

struct MapView: View {
	@State var coordinate: CLLocationCoordinate2D

	var body: some View {
		Map(position: .constant(.region(region))) {
			Marker("Note", coordinate: coordinate)
		}
	}

	private var region: MKCoordinateRegion {
		MKCoordinateRegion(
			center: coordinate,
			span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
		)
	}
}

#Preview {
	MapView(coordinate: CLLocationCoordinate2D(latitude: 33.302_6129, longitude: -111.732_8528))
}
