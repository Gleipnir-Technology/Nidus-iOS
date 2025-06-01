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

struct RoundedButton: ButtonStyle {
	var fillColor: Color
	var padding: CGFloat

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.colorInvert()
			.padding(.all, padding)
			.background(fillColor.opacity(configuration.isPressed ? 0.8 : 1))
			.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
			.animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
	}
}

struct AsyncButton<Label: View>: View {
	@State private var isPerformingTask = false

	var action: () async -> Void
	@ViewBuilder var label: () -> Label

	var body: some View {
		Button(
			action: {
				isPerformingTask = true
				Task {
					await action()
					isPerformingTask = false
				}
			},
			label: {
				label().opacity(isPerformingTask ? 0.5 : 1)
			}
		)
		.disabled(isPerformingTask)
	}
}

extension AsyncButton where Label == Text {
	init(_ label: String, action: @escaping () async -> Void) {
		self.init(action: action) {
			Text(label)
		}
	}
}

struct LazyView<Content: View>: View {
	let build: () -> Content

	init(_ build: @autoclosure @escaping () -> Content) {
		self.build = build
	}

	var body: Content {
		build()
	}
}

extension CLLocationCoordinate2D {
	static func random(
		minLatitude: Double,
		maxLatitude: Double,
		minLongitude: Double,
		maxLongitude: Double
	) -> CLLocationCoordinate2D {
		let latitudeDelta = maxLatitude - minLatitude
		let longitudeDelta = maxLongitude - minLongitude

		let latitude = minLatitude + latitudeDelta * Double.random(in: 0...1)
		let longitude = minLongitude + longitudeDelta * Double.random(in: 0...1)

		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}

extension MKCoordinateRegion {
	var maxLongitude: CLLocationDegrees { center.longitude + span.longitudeDelta / 2 }
	var minLongitude: CLLocationDegrees { center.longitude - span.longitudeDelta / 2 }
	var maxLatitude: CLLocationDegrees { center.latitude + span.latitudeDelta / 2 }
	var minLatitude: CLLocationDegrees { center.latitude - span.latitudeDelta / 2 }
}

extension MKCoordinateRegion {
	func randomCoordinate() -> CLLocationCoordinate2D {
		.random(
			minLatitude: minLatitude,
			maxLatitude: maxLatitude,
			minLongitude: minLongitude,
			maxLongitude: maxLongitude
		)
	}
}

public struct CoordinateRandomizer {
	public init() {}

	public func generateRandomCoordinates(count: Int, within region: MKCoordinateRegion)
		-> [CLLocationCoordinate2D]
	{
		(0..<count).map { _ in
			region.randomCoordinate()
		}
	}
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

@Observable
final class DataSource: ObservableObject {
	private let coordinateRandomizer = CoordinateRandomizer()
	private let clusterManager = ClusterManager<ExampleAnnotation>()

	var annotations: [ExampleAnnotation] = []
	var clusters: [ExampleClusterAnnotation] = []

	var mapSize: CGSize = .zero
	var currentRegion: MKCoordinateRegion = .sanFrancisco

	func addAnnotations() async {
		let points = coordinateRandomizer.generateRandomCoordinates(
			count: 10000,
			within: currentRegion
		)
		let newAnnotations = points.map {
			ExampleAnnotation(color: .red, coordinate: $0, systemImage: "mappin")
		}
		await clusterManager.add(newAnnotations)
		await reloadAnnotations()
	}

	func removeAnnotations() async {
		await clusterManager.removeAll()
		await reloadAnnotations()
	}

	func reloadAnnotations() async {
		async let changes = clusterManager.reload(
			mapViewSize: mapSize,
			coordinateRegion: currentRegion
		)
		await applyChanges(changes)
	}

	@MainActor
	private func applyChanges(
		_ difference: ClusterManager<ExampleAnnotation>.Difference
	) {
		for removal in difference.removals {
			switch removal {
			case .annotation(let annotation):
				annotations.removeAll { $0 == annotation }
			case .cluster(let clusterAnnotation):
				clusters.removeAll { $0.id == clusterAnnotation.id }
			}
		}
		for insertion in difference.insertions {
			switch insertion {
			case .annotation(let newItem):
				annotations.append(newItem)
			case .cluster(let newItem):
				clusters.append(
					ExampleClusterAnnotation(
						id: newItem.id,
						coordinate: newItem.coordinate,
						count: newItem.memberAnnotations.count
					)
				)
			}
		}
	}
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
		.readSize(onChange: { newValue in
			dataSource.mapSize = newValue
		})
		.onMapCameraChange { context in
			dataSource.currentRegion = context.region
		}
		.onMapCameraChange(frequency: .onEnd) { context in
			Task.detached { await dataSource.reloadAnnotations() }
			Task.detached { onPositionChange(context.region) }
		}
		.overlay(
			alignment: .bottom,
			content: {
				HStack {
					Spacer()
					AsyncButton("Remove annotations") {
						await dataSource.removeAnnotations()
					}
				}
				.padding()
				.buttonStyle(RoundedButton(fillColor: .accentColor, padding: 8))
			}
		)
	}
}

/*
@available(iOS 17.0, *)
#Preview {
	ModernMap()
}
*/
