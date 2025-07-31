// From https://medium.com/@emrdgrmnci/map-annotation-clustering-in-ios-17-e43e94f9db60

import ClusterMap
import Foundation
import MapKit

struct ExampleClusterAnnotation: Identifiable {
	var id = UUID()
	var coordinate: CLLocationCoordinate2D
	var count: Int
}

@Observable
class LocalSearchCompleter: NSObject {
	var mapSize: CGSize = .zero
	var currentRegion: MKCoordinateRegion = .userLocation
	var annotations = [MKMapItem]()  // #1 element of the tree
	var clusters = [ExampleClusterAnnotation]()  // #2 element of the tree

	let customConfig = ClusterManager<MKMapItem>.Configuration(
		cellSizeForZoomLevel: { (zoom: Int) -> CGSize in
			switch zoom {
			case 13...15: return CGSize(width: 64, height: 64)  // grid size used in clustering
			case 16...18: return CGSize(width: 32, height: 32)
			case 19...: return CGSize(width: 16, height: 16)
			default: return CGSize(width: 88, height: 88)
			}
		}
	)

	var clusterManager: ClusterManager<MKMapItem>

	override init() {
		clusterManager = ClusterManager<MKMapItem>(configuration: customConfig)
	}

	func search(for query: String) async {
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = query
		request.region = currentRegion
		do {
			async let searchResult = MKLocalSearch(request: request).start()
			await clusterManager.removeAll()
			try await clusterManager.add(searchResult.mapItems)
			await reloadAnnotations()
		}
		catch {
			assertionFailure("Error: \(error.localizedDescription)")
		}
	}

	func reloadAnnotations() async {
		async let changes = clusterManager.reload(
			mapViewSize: mapSize,
			coordinateRegion: currentRegion
		)
		await applyChanges(changes)
	}

	@MainActor
	private func applyChanges(_ difference: ClusterManager<MKMapItem>.Difference) {
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

extension MKMapItem: CoordinateIdentifiable, Identifiable {
	public var id: String {
		placemark.region?.identifier ?? UUID().uuidString
	}

	public var coordinate: CLLocationCoordinate2D {
		get { placemark.coordinate }
		set(newValue) {}
	}
}
