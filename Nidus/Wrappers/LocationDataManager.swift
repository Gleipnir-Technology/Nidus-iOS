//
//  Location.swift
//  Nidus
//
//  Created by Cole Dennis on 9/21/22
//  from https://github.com/coledennis/CoreLocationSwiftUITutorial/blob/main/CoreLocationSwiftUITutorial/LocationDataManager.swift
//

import CoreLocation
import Foundation
import OSLog
import SwiftUI

@Observable
class LocationDataManager: NSObject, CLLocationManagerDelegate {
	var authorizationStatus: CLAuthorizationStatus
	var allowAuthorizationChange: Bool
	private var onLocationAcquiredCallbacks: [((CLLocation) -> Void)] = []
	private var onLocationUpdatedCallbacks: [(([CLLocation]) -> Void)] = []
	var isPrecise: Bool = false
	var location: CLLocation? = nil
	private var locationManager = CLLocationManager()

	init(authorizationStatus: CLAuthorizationStatus? = nil) {
		// Specifying the authorization status here is useful for previews
		// to keep the preview in a static state
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

	// Register a callback to be fired when location data is first acquired
	// Callback will be called at most once per registration
	func onLocationAcquired(_ action: @escaping (CLLocation) -> Void) {
		if location != nil {
			action(location!)
			return
		}
		onLocationAcquiredCallbacks.append(action)
	}

	// Register a callback to be fired every time location data is updated
	func onLocationUpdated(_ callback: @escaping ([CLLocation]) -> Void) {
		onLocationUpdatedCallbacks.append(callback)
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		Logger.background.info(
			"Location data manager authorization change: \(manager.authorizationStatus.rawValue)"
		)
		if !allowAuthorizationChange {
			Logger.background.info(
				"Location data manager authorization change: not allowing change"
			)
			return
		}
		switch manager.authorizationStatus {
		case .authorizedWhenInUse:  // Location services are available.
			// Insert code here of what should happen when Location services are authorized
			authorizationStatus = .authorizedWhenInUse
			isPrecise = manager.accuracyAuthorization == .fullAccuracy
			//locationManager.requestLocation()
			locationManager.startUpdatingLocation()
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
			if self.allowAuthorizationChange {
				manager.requestWhenInUseAuthorization()
			}
			break

		default:
			break
		}
	}

	func locationManager(
		_ manager: CLLocationManager,
		didUpdateLocations locations: [CLLocation]
	) {
		let location = locations.last
		self.location = location
		notifyAcquiredCallbacks()
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("error: \(error.localizedDescription)")
	}

	private func notifyAcquiredCallbacks() {
		while !onLocationAcquiredCallbacks.isEmpty {
			let callback = onLocationAcquiredCallbacks.removeFirst()
			callback(location!)
		}
	}
}

// A location data manager that will never get a fix
@Observable
class LocationDataManagerFake: LocationDataManager {
	init(location: CLLocation? = nil) {
		super.init(authorizationStatus: .notDetermined)
		self.location = location
	}
}
