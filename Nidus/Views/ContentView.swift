//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var context
	@State var locationDataManager: LocationDataManager = LocationDataManager()

	var body: some View {
		TabView {
			NoteListView(userLocation: locationDataManager.location).tabItem {
				Label("Notes", systemImage: "pencil")
			}
			NoteMapView().tabItem {
				Label("Map", systemImage: "map")
			}
			SettingView().tabItem {
				Label("Settings", systemImage: "gearshape")
			}
		}
	}
}

#Preview("Loading") {
	ContentView().modelContainer(try! ModelContainer.sample())
}
