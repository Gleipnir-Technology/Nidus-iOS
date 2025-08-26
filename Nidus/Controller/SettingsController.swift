import MapKit
import OSLog
import SwiftUI

@Observable
class SettingsController {
	var model = SettingsModel()

	// MARK - public interface
	func load() {
		model.password = UserDefaults.standard.string(forKey: "password") ?? ""
		model.URL =
			UserDefaults.standard.string(forKey: "sync-url")
			?? "https://sync.nidus.cloud"
		model.username = UserDefaults.standard.string(forKey: "username") ?? ""

		model.region = loadCurrentRegion() ?? Initial.region
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
		//Logger.background.info("Saved current region: \(regionString)")
	}

	func saveSync(password: String, url: String, username: String) {
		model.password = password
		model.URL = url
		model.username = username
		UserDefaults.standard.set(password, forKey: "password")
		UserDefaults.standard.set(url, forKey: "sync-url")
		UserDefaults.standard.set(username, forKey: "username")
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
		Logger.foreground.info("Loaded current region: \(regionString)")
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
