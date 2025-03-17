//
//  Location.swift
//  Nidus
//
//  Created by Cole Dennis on 9/21/22
//  from https://github.com/coledennis/CoreLocationSwiftUITutorial/blob/main/CoreLocationSwiftUITutorial/LocationDataManager.swift
//

import CoreLocation
import Foundation

@Observable
class LocationDataManager: NSObject, CLLocationManagerDelegate {
	var locationManager = CLLocationManager()
	var authorizationStatus: CLAuthorizationStatus
	var allowAuthorizationChange: Bool

	init(authorizationStatus: CLAuthorizationStatus? = nil) {
		// Used to control what is shown in Preview
		if let status = authorizationStatus {
			self.authorizationStatus = status
			self.allowAuthorizationChange = false
		}
		else {
			self.authorizationStatus = .notDetermined
			self.allowAuthorizationChange = true
		}
		super.init()
		locationManager.delegate = self
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if !allowAuthorizationChange {
			return
		}
		switch manager.authorizationStatus {
		case .authorizedWhenInUse:  // Location services are available.
			// Insert code here of what should happen when Location services are authorized
			authorizationStatus = .authorizedWhenInUse
			locationManager.requestLocation()
			break

		case .restricted:  // Location services currently unavailable.
			// Insert code here of what should happen when Location services are NOT authorized
			authorizationStatus = .restricted
			break

		case .denied:  // Location services currently unavailable.
			// Insert code here of what should happen when Location services are NOT authorized
			authorizationStatus = .denied
			break

		case .notDetermined:  // Authorization not determined yet.
			authorizationStatus = .notDetermined
			manager.requestWhenInUseAuthorization()
			break

		default:
			break
		}
	}

	func locationManager(
		_ manager: CLLocationManager,
		didUpdateLocations locations: [CLLocation]
	) {
		// Insert code to handle location updates
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("error: \(error.localizedDescription)")
	}
}
