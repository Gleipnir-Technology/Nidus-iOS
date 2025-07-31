//
//  TrapDataDetail.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/22/25.
//

import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct TrapDataDetail: View {
	let onFilterAdded: (FilterInstance) -> Void
	@State private var showFilterToast = false
	let trapData: TrapData

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
						center: trapData.coordinate,
						span: MKCoordinateSpan.init(
							latitudeDelta: 0.005,
							longitudeDelta: 0.005
						)
					)
				)
			) {
				Marker(
					"\(trapData.name)",
					systemImage: trapData.category.icon,
					coordinate: trapData.coordinate
				)
			}.frame(height: 300)
			Text("Trap Data")
			Text(
				"Location \(trapData.coordinate.latitude), \(trapData.coordinate.longitude)"
			)
		}.toast(message: "Filter saved", isShowing: $showFilterToast, duration: Toast.short)
	}
}

struct TrapDataDetail_Previews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			TrapDataDetail(
				onFilterAdded: { _ in },
				trapData: TrapData(
					created: Date.now.addingTimeInterval(-10000),
					description: "a nice little trap",
					id: UUID(),
					location: Location(latitude: 33.3, longitude: -111.1),
					name: "the best trap"
				)
			)
		}
	}
}
