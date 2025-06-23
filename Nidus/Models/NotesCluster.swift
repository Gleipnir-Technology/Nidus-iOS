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
	private let clusterManager = ClusterManager<ExampleAnnotation>()

	var annotations: [ExampleAnnotation] = []
	var clusters: [ExampleClusterAnnotation] = []

	var mapSize: CGSize = .zero
	var currentRegion: MKCoordinateRegion = .visalia

	func onNoteChanges(_ notes: [AnyNote]) async {
		Logger.background.info("Detected changes in note cluster: \(notes.count) notes now")
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
