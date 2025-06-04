//
//  NidusApp.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//
import SwiftData
import SwiftUI
import UIKit

@MainActor
let appContainer: ModelContainer = {
	do {
		let schema = Schema([
			NoteLocation.self
		])
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
	@State private var locationDataManager = LocationDataManager()
	@State private var model = NidusModel()
	@UIApplicationDelegateAdaptor private var appDelegate: NidusAppDelegate

	var body: some Scene {
		WindowGroup {
			ContentView(
				model: model,
				onAppear: model.triggerBackgroundFetch,
				onMapPositionChange: model.setPosition
			).environment(locationDataManager)
		}
		.modelContainer(appContainer)
	}
}

class NidusAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
	var backgroundCompletionHandler: (() -> Void)?

	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		// Record the device token
	}

	func application(
		_ application: UIApplication,
		handleEventsForBackgroundURLSession identifier: String,
		completionHandler: @escaping () -> Void
	) {
		backgroundCompletionHandler = completionHandler
	}
}
