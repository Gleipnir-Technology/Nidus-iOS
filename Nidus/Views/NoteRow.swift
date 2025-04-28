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

	var note: Note
	var userLocation: CLLocation?

	func distanceString() -> String {
		if let ul = userLocation {
			let noteLocation = CLLocation(
				latitude: note.location.latitude,
				longitude: note.location.longitude
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

#Preview("0.1m", traits: .modifier(MockDataPreviewModifier())) {
	NoteRow(
		note: Note.dog,
		userLocation: CLLocation(
			latitude: Note.dog.location.latitude + 0.000_002,
			longitude: Note.dog.location.longitude + 0.000_003
		)
	)
}
#Preview("1m", traits: .modifier(MockDataPreviewModifier())) {
	NoteRow(
		note: Note.dog,
		userLocation: CLLocation(
			latitude: Note.dog.location.latitude + 0.000_2,
			longitude: Note.dog.location.longitude + 0.000_3
		)
	)
}
#Preview("100m", traits: .modifier(MockDataPreviewModifier())) {
	NoteRow(
		note: Note.dog,
		userLocation: CLLocation(
			latitude: Note.dog.location.latitude + 0.002,
			longitude: Note.dog.location.longitude + 0.003
		)
	)
}
#Preview("1000m", traits: .modifier(MockDataPreviewModifier())) {
	NoteRow(
		note: Note.dog,
		userLocation: CLLocation(
			latitude: Note.dog.location.latitude + 0.02,
			longitude: Note.dog.location.longitude + 0.03
		)
	)
}
