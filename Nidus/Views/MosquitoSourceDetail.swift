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
			if source.inspections.isEmpty {
				Text("No inspections recorded")
			}
			else {
				NavigationLink {
					InspectionList(inspections: source.inspections)
				} label: {
					Label("Inspections", systemImage: "magnifyingglass")
				}
			}
			if source.treatments.isEmpty {
				Text("No treatments recorded")
			}
			else {
				NavigationLink {
					TreatmentList(treatments: source.treatments)
				} label: {
					Label("Treatments", systemImage: "hazardsign")
				}
			}
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
			inspections: [
				Inspection(
					comments: "it was gross",
					condition: "bad",
					created: Date.now.addingTimeInterval(-5000),
					id: UUID()
				),
				Inspection(
					comments: "it was not too bad",
					condition: "acceptable",
					created: Date.now.addingTimeInterval(-3000),
					id: UUID()
				),
			],
			name: "drain pipe",
			treatments: [],
			useType: "not used",
			waterOrigin: "humans"
		)
	)
}
