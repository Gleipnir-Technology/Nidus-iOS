//
//  NidusApp.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//
import SwiftData
import SwiftUI

@MainActor
let appContainer: ModelContainer = {
	do {
		let schema = Schema([Note.self, NoteLocation.self, Settings.self])
		let container = try ModelContainer(for: schema)

		return container
	}
	catch {
		fatalError("Failed to create container")
	}
}()

@main
@MainActor
struct NidusApp: App {
	@State private var modelData = ModelData()
	@State private var locationDataManager = LocationDataManager()
	var body: some Scene {
		WindowGroup {
			ContentView().environment(locationDataManager)
		}
		.modelContainer(appContainer)
	}
}
