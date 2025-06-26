import AVFoundation
import CoreLocation
import Speech
import SwiftUI

struct AddNoteView: View {
	@State private var audioRecorder: AudioRecorder
	@Environment(\.locale) var locale
	@State var location: CLLocation?

	var locationDataManager: LocationDataManager

	init(location: CLLocation?, locationDataManager: LocationDataManager) {
		self._audioRecorder = .init(wrappedValue: AudioRecorder())
		self._location = .init(wrappedValue: location)
		self.locationDataManager = locationDataManager
	}

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
			LocationView(location: $location).frame(height: 300)
			Text("Where: \(locationDescription)")

			AudioRecorderView(audioRecorder: audioRecorder)
			Text("Transcription:")
			ScrollView {
				Text(audioRecorder.transcribedText)
					.padding()
					.frame(
						maxWidth: .infinity,
						alignment: .leading
					)
					.background(Color.blue.opacity(0.1))
					.cornerRadius(10)
			}
			.frame(maxHeight: 150)
			Spacer()
		}
	}

}

// MARK: - Preview
struct AddNoteView_Previews: PreviewProvider {
	static var previews: some View {
		AddNoteView(
			location: nil,
			locationDataManager: LocationDataManager()
		)
		AddNoteView(
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: LocationDataManagerFake(
				location: nil
			)
		)
		AddNoteView(
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			)
		)
	}
}
