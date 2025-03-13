//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftUI

class ViewModel: ObservableObject {
	@Published var text: String = "Getting location..."
}

struct ContentView: View {
	@StateObject var locationDataManager = LocationDataManager()
	@StateObject private var viewModel: ViewModel

	init(viewModel: ViewModel = ViewModel()) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}

	var body: some View {
		VStack {
			switch locationDataManager.locationManager.authorizationStatus {
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

#Preview("Before Location") {
	ContentView().environment(ModelData())
}

#Preview("After Location") {
	ContentView(
		viewModel: {
			let vm = ViewModel()
			vm.text = "Test Value"
			return vm
		}()
	)
}
