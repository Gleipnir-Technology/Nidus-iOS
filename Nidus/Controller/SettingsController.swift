import MapKit
import OSLog
import SwiftUI

@Observable
class SettingsController {
	var callbacks: [(SettingsModel) -> Void] = []
	var model = SettingsModel()

	// MARK - public interface
	func load() {
		withObservationTracking {
			model.password = UserDefaults.standard.string(forKey: "password") ?? ""
			model.URL =
				UserDefaults.standard.string(forKey: "sync-url")
				?? "https://sync.nidus.cloud"
			model.username = UserDefaults.standard.string(forKey: "username") ?? ""

			model.region = loadCurrentRegion() ?? Initial.region
		} onChange: {
			Logger.foreground.info("Got new settings")
		}
	}

	func onAppear() {
	}

	func onChanged(_ callback: @escaping (SettingsModel) -> Void) {
		callbacks.append(callback)
	}

	func saveCurrentRegion(_ region: MKCoordinateRegion) {
		let regionString = String(
			format: "%f,%f,%f,%f",
			region.center.latitude,
			region.center.longitude,
			region.span.latitudeDelta,
			region.span.longitudeDelta
		)
		UserDefaults.standard.set(regionString, forKey: "currentRegion")
	}

	// MARK - private functions
	private func loadCurrentRegion() -> MKCoordinateRegion? {
		guard let regionString = UserDefaults.standard.string(forKey: "currentRegion")
		else {
			return nil
		}
		if regionString == "" {
			return nil
		}
		let scanner = Scanner(string: regionString)
		guard let latitude = scanner.scanDouble() else {
			return nil
		}
		_ = scanner.scanCharacter()  // drop the ","
		guard let longitude = scanner.scanDouble() else {
			return nil
		}
		_ = scanner.scanCharacter()  // drop the ","
		guard let latitudeDelta = scanner.scanDouble() else {
			return nil
		}
		_ = scanner.scanCharacter()  // drop the ","
		guard let longitudeDelta = scanner.scanDouble() else {
			return nil
		}
		let region: MKCoordinateRegion = .init(
			center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
			span: MKCoordinateSpan(
				latitudeDelta: latitudeDelta,
				longitudeDelta: longitudeDelta
			)
		)
		return region
	}

}
