import AVFoundation
import CoreLocation
import Speech
import SwiftUI

struct AddNoteView: View {
	@StateObject private var audioRecorder = AudioRecorder()
	@Environment(\.locale) var locale
	@State var location: CLLocation?

	var locationDataManager: LocationDataManager

	var locationDescription: String {
		guard let location = location else {
			return "current location"
		}
		guard let userLocation = locationDataManager.location else {
			return "...getting a fix"
		}
		let distance = Measurement(
			value: location.distance(from: userLocation),
			unit: UnitLength.meters
		)
		return distance.formatted(
			.measurement(width: .abbreviated, usage: .road).locale(locale)
		) + " away"
	}
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("New note")
				.font(.title)
				.fontWeight(.bold)
			Text("Where: \(locationDescription)")
			LocationView(location: $location).frame(height: 300)

			AudioRecorderView()
		}
	}

}

// MARK: - Preview
struct AddNoteViewCurrentLocation_Previews: PreviewProvider {
	@State static var locationDataManager: LocationDataManager = LocationDataManager()
	static var previews: some View {
		AddNoteView(
			location: nil,
			locationDataManager: locationDataManager
		)
	}
}

struct AddNoteViewNoLocation_Previews: PreviewProvider {
	@State static var locationDataManager: LocationDataManager = LocationDataManagerFake(
		location: nil
	)
	static var previews: some View {
		AddNoteView(
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: locationDataManager
		)
	}
}

struct AddNoteViewWithLocation_Previews: PreviewProvider {
	@State static var locationDataManager: LocationDataManager = LocationDataManagerFake(
		location: CLLocation(latitude: 33.0, longitude: -161.5)
	)
	static var previews: some View {
		AddNoteView(
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: locationDataManager
		)
	}
}
