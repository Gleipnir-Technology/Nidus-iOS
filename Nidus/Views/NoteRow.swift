//
//  NoteRow.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//
import CoreLocation
import SwiftUI

struct NoteRow: View {
	@Environment(\.locale) var locale

	var note: any Note
	var userLocation: CLLocation?

	func distanceString() -> String {
		if let ul = userLocation {
			let noteLocation = CLLocation(
				latitude: note.coordinate.latitude,
				longitude: note.coordinate.longitude
			)
			let distance = Measurement(
				value: noteLocation.distance(from: ul),
				unit: UnitLength.meters
			)
			return distance.formatted(
				.measurement(width: .abbreviated, usage: .road).locale(
					locale
				)
			)
		}
		else {
			return "?m "
		}
	}
	var body: some View {
		HStack {
			VStack {
				Label("", systemImage: note.category.icon)
				Text(distanceString())
			}
			Text(note.content)
			Spacer()
		}
		.padding()
	}
}

#Preview {
	NoteRow(
		note: ServiceRequest(
			address: "somewhere",
			city: "over there",
			created: Date.now,
			id: UUID(uuidString: "1846d421-f8ab-4e37-850a-b61bb8422453")!,
			location: Location(latitude: 30, longitude: -111),
			priority: "low",
			source: "everywhere",
			status: "bad",
			target: "here",
			zip: "12345"
		),
		userLocation: nil
	)
}
