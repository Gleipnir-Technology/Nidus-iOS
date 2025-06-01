//
//  MosquitoSourceDetail.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/1/25.
//
import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct MosquitoSourceDetail: View {
	let source: MosquitoSource

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
						center: source.coordinate,
						span: MKCoordinateSpan.init(
							latitudeDelta: 0.005,
							longitudeDelta: 0.005
						)
					)
				)
			) {
				Marker(
					"\(source.name)",
					systemImage: source.category.icon,
					coordinate: source.coordinate
				)
			}.frame(height: 300)
			Text("Mosquito Source")
			Text(
				"Location \(source.coordinate.latitude), \(source.coordinate.longitude)"
			)
			Text("Access: \(source.access)")
			Text("Comments: \(source.comments)")
			Text("Created: \(createdFormatted(source.created))")
			Text("Description: \(source.description)")
			Text("Habitat: \(source.habitat)")
			Text("Name: \(source.name)")
			Text("Use Type: \(source.useType)")
			Text("Water Origin: \(source.waterOrigin)")
		}
	}
}

#Preview {
	MosquitoSourceDetail(
		source: MosquitoSource(
			access: "somewhere",
			comments: "over there",
			created: Date.now.addingTimeInterval(-15000),
			description: "dank",
			id: UUID(uuidString: "1846d421-f8ab-4e37-850a-b61bb8422453")!,
			location: Location(latitude: 33.3, longitude: -111.1),
			habitat: "everywhere",
			inspections: [],
			name: "drain pipe",
			treatments: [],
			useType: "not used",
			waterOrigin: "humans"
		)
	)
}
