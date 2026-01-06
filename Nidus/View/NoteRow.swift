import CoreLocation
import H3
import SwiftUI

struct NoteRow: View {
	@Environment(\.locale) var locale

	var currentLocation: CLLocation?
	var note: any Note

	func distanceString() -> String {
		if let ul = currentLocation {
			do {
				let l = try cellToLatLng(cell: note.h3cell)
				let noteLocation = CLLocation(
					latitude: l.latitude,
					longitude: l.longitude
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
			catch {
				return "?m"
			}
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
		currentLocation: nil,
		note: ServiceRequest(
			address: "somewhere",
			assignedTechnician: "John Doe",
			city: "over there",
			created: Date.now,
			h3cell: .visalia,
			hasDog: false,
			hasSpanishSpeaker: false,
			id: UUID(uuidString: "1846d421-f8ab-4e37-850a-b61bb8422453")!,
			priority: "low",
			source: "everywhere",
			status: "bad",
			target: "here",
			zip: "12345"
		)
	)
}
