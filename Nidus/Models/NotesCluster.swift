//
//  NodesCluster.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//

import ClusterMap
import ClusterMapSwiftUI
import MapKit
import OSLog
import SwiftData
import SwiftUI

@Observable
final class NotesCluster: ObservableObject {
	private let coordinateRandomizer = CoordinateRandomizer()
	private let clusterManager = ClusterManager<ExampleAnnotation>()

	//var annotations: [AnyNote] = []
	var annotations: [ExampleAnnotation] = []
	var clusters: [ExampleClusterAnnotation] = []

	var mapSize: CGSize = .zero
	var currentRegion: MKCoordinateRegion = .visalia

	func addNotes(_ notes: [AnyNote]) async {
		/*annotations = notes
        await clusterManager.add(notes)
        await reloadAnnotations()*/
		let newAnnotations = notes.map {
			ExampleAnnotation(
				color: $0.color,
				coordinate: $0.coordinate,
				systemImage: $0.category.icon
			)
		}
		await clusterManager.removeAll()
		await clusterManager.add(newAnnotations)
		await reloadAnnotations()
	}

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
