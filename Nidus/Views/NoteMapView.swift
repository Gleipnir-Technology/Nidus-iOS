//
//  NoteMapView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/19/25.
//
import MapKit
import SwiftUI

struct NoteMapView: View {

	//@State var currentLocation: CLLocationCoordinate2D
	//@State var notes: [Note]
	@State private var region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 37.3318, longitude: -121.8863),
		span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
	)

	var body: some View {
		Map(coordinateRegion: $region)
	}
}

/*#Preview {
    NoteMapView().environment(LocationDataManagerForPreview())
}*/
