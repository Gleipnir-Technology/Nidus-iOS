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
	@State var currentValue: Float = 0.0

	var body: some View {
		TabView {
			NoteListView(userLocation: locationDataManager.location).tabItem {
				Label("Notes", systemImage: "clock")
			}
			MapOverview(userLocation: locationDataManager.location).tabItem {
				Label("Map", systemImage: "map")
			}
		}
	}
}

#Preview("Loading") {
	ContentView().modelContainer(try! ModelContainer.sample())
}
