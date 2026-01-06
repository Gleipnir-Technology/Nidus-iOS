//
//  ServiceRequestDetail.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/22/25.
//

import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct ServiceRequestDetail: View {
	let onFilterAdded: (FilterInstance) -> Void
	@State private var showFilterToast = false
	let request: ServiceRequest

	private func addFilter(_ type: any Filter, _ value: String) {
		showFilterToast = true
		onFilterAdded(FilterInstance(type, value))
	}

	func createdFormatted(_ created: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDate = formatter.localizedString(for: created, relativeTo: Date.now)
		return relativeDate
	}
	var body: some View {
		Form {
			Map(
				initialPosition: MapCameraPosition.region(
					MKCoordinateRegion(
						center: request.coordinate,
						span: MKCoordinateSpan.init(
							latitudeDelta: 0.005,
							longitudeDelta: 0.005
						)
					)
				)
			) {
				Marker(
					"\(request.address)",
					systemImage: request.category.icon,
					coordinate: request.coordinate
				)
			}.frame(height: 300)
			Text("Service Request")
			Text("Created \(createdFormatted(request.created))")
			Text(
				"Location \(request.coordinate.latitude), \(request.coordinate.longitude)"
			)
			Text("Address: \(request.address)")
			Text("City: \(request.city)")
			Text("Zip: \(request.zip)")
			FilterableField(
				filter: filters.assignedTechnician,
				label: "Assigned Technician",
				value: request.assignedTechnician,
				addFilter: addFilter
			)
			FilterableField(
				filter: filters.hasDog,
				label: "Dog",
				value: request.hasDog?.description ?? "Unknown",
				addFilter: addFilter
			)
			FilterableField(
				filter: filters.hasSpanishSpeaker,
				label: "Spanish-speaking",
				value: request.hasSpanishSpeaker?.description ?? "Unknown",
				addFilter: addFilter
			)
			FilterableField(
				filter: filters.priority,
				label: "Priority",
				value: request.priority,
				addFilter: addFilter
			)
			FilterableField(
				filter: filters.source,
				label: "Source",
				value: request.source,
				addFilter: addFilter
			)
			FilterableField(
				filter: filters.status,
				label: "Status",
				value: request.status,
				addFilter: addFilter
			)
			FilterableField(
				filter: filters.target,
				label: "Target",
				value: request.target,
				addFilter: addFilter
			)
		}.toast(message: "Filter saved", isShowing: $showFilterToast, duration: Toast.short)
	}
}

struct ServiceRequestDetail_Previews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			ServiceRequestDetail(
				onFilterAdded: { _ in },
				request: ServiceRequest(
					address: "123 Main Street",
					assignedTechnician: "Phil A'hole",
					city: "Townsville",
					created: Date.now.addingTimeInterval(-10000),
					h3cell: .visalia,
					hasDog: false,
					hasSpanishSpeaker: true,
					id: UUID(),
					priority: "high",
					source: "phone",
					status: "dire",
					target: "red leader",
					zip: "85291"
				)
			)
		}
	}
}
