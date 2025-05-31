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
			Label(note.category.name, systemImage: note.category.icon)
			Text(distanceString())
			Spacer()
		}
		.padding()
	}
}
