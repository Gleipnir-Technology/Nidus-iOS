//
//  MapClustered.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import ClusterMap
import ClusterMapSwiftUI
import MapKit
import SwiftUI

extension MKCoordinateRegion {
	var maxLongitude: CLLocationDegrees { center.longitude + span.longitudeDelta / 2 }
	var minLongitude: CLLocationDegrees { center.longitude - span.longitudeDelta / 2 }
	var maxLatitude: CLLocationDegrees { center.latitude + span.latitudeDelta / 2 }
	var minLatitude: CLLocationDegrees { center.latitude - span.latitudeDelta / 2 }
}

extension MKCoordinateRegion {
	public static var sanFrancisco: MKCoordinateRegion {
		.init(
			center: CLLocationCoordinate2D(
				latitude: 37.787_994,
				longitude: -122.407_437
			),
			span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
		)
	}
	public static var visalia: MKCoordinateRegion {
		.init(
			center: CLLocationCoordinate2D(
				latitude: 36.326,
				longitude: -119.313191
			),
			span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
		)
	}
}

// MapKit (MKMapItem) integration
/*
extension MKMapItem: CoordinateIdentifiable, Identifiable, Hashable {
  let id = UUID()
  var coordinate: CLLocationCoordinate2D {
    get { placemark.coordinate }
    set(newValue) { }
  }
}

// MapKit (MKPointAnnotation) integration
class ExampleAnnotation: MKPointAnnotation, CoordinateIdentifiable, Identifiable, Hashable {
  let id = UUID()
}
*/

struct ExampleAnnotation: Identifiable, CoordinateIdentifiable, Hashable {
	var id = UUID()
	var color: Color
	var coordinate: CLLocationCoordinate2D
	var systemImage: String
}

struct ExampleClusterAnnotation: Identifiable {
	var id = UUID()
	var coordinate: CLLocationCoordinate2D
	var count: Int
}

@available(iOS 17.0, *)
struct ModernMap: View {
	@State var dataSource: NotesCluster
	var onPositionChange: ((MKCoordinateRegion) -> Void)

	func asMarker(_ item: ExampleAnnotation) -> some MapContent {
		return Marker(
			"\(item.coordinate.latitude) \(item.coordinate.longitude)",
			systemImage: item.systemImage,
			coordinate: item.coordinate
		)
		.annotationTitles(.hidden)
		.tint(item.color)
	}

	var body: some View {
		Map(
			initialPosition: .region(dataSource.currentRegion),
			interactionModes: .all
		) {
			ForEach(dataSource.annotations) { item in
				asMarker(item)
			}
			ForEach(dataSource.clusters) { item in
				Marker(
					"\(item.count)",
					systemImage: "square.3.layers.3d",
					coordinate: item.coordinate
				).tint(.yellow)
			}
		}
		.mapStyle(.hybrid)
		.mapControls {
			MapUserLocationButton()
		}
		.readSize(onChange: { newValue in
			dataSource.mapSize = newValue
		})
		.onMapCameraChange { context in
			dataSource.currentRegion = context.region
		}
		.onMapCameraChange(frequency: .onEnd) { context in
			Task.detached { await dataSource.reloadAnnotations() }
			Task.detached { await onPositionChange(context.region) }
		}
	}
}

/*
@available(iOS 17.0, *)
#Preview {
	ModernMap()
}
*/
