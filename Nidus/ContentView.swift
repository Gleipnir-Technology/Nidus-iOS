//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationDataManager = LocationDataManager()
    
    var body: some View {
        VStack {
            switch locationDataManager.locationManager.authorizationStatus {
            case .authorizedWhenInUse: // location services are available.
                Text("Your current location is:")
                Text("Latitude: \(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")")
                Text("Longitude: \(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
                Text("Precision: \(locationDataManager.locationManager.location?.horizontalAccuracy.formatted() ?? "Error loading")")
            case .restricted, .denied: // Not available
                Text("Current location data was restricted or denied.")
            case .notDetermined: // not determined yet
                Text("Finding your location...")
                ProgressView()
            default:
                ProgressView()
            }
        }
        /*
        NavigationSplitView {
            ZStack {
                NoteList()
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink {
                            NoteCreation()
                        } label: {
                            ButtonAddNote()
                        }
                    }
                }
            }
            .navigationTitle("Notes")
        } detail: {
            Text("Nidus")
        }*/
    }
}

#Preview {
    ContentView().environment(ModelData())
}
