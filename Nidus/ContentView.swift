//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftUI

@Observable
class ViewModel {
	var text: String

	init(text: String = "Getting location...") {
		self.text = text
	}
}

struct ContentView: View {
	@State private var locationDataManager: LocationDataManager
	@State private var viewModel: ViewModel

	init(
		locationDataManager: LocationDataManager = LocationDataManager(),
		viewModel: ViewModel = ViewModel()
	) {
		self.locationDataManager = locationDataManager
		self.viewModel = viewModel
	}

	var body: some View {
		VStack {
			switch locationDataManager.authorizationStatus {
			case .authorizedWhenInUse:  // location services are available.
				Text("Your current location is:")
				Text(
					"Latitude: \(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")"
				)
				Text(
					"Longitude: \(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")"
				)
				Text(
					"Precision: \(locationDataManager.locationManager.location?.horizontalAccuracy.formatted() ?? "Error loading")"
				)
			case .restricted, .denied:  // Not available
				Text("Current location data was restricted or denied.")
			case .notDetermined:  // not determined yet
				Text(viewModel.text)
				ProgressView()
			default:
				ProgressView()
			}
		}
	}
}

#Preview("Loading") {
	ContentView().environment(ModelData())
}

#Preview("Denied") {
	var vm = ViewModel(text: "Testing...")
	var ld = LocationDataManager(authorizationStatus: .denied)
	ContentView(locationDataManager: ld, viewModel: vm)
}
