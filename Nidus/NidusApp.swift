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
			MosquitoSource.self,
			NoteLocation.self,
			ServiceRequest.self,
			Settings.self,
			TrapData.self,
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
	@State private var modelData = ModelData()
	@State private var locationDataManager = LocationDataManager()
	@UIApplicationDelegateAdaptor private var appDelegate: NidusAppDelegate

	var body: some Scene {
		WindowGroup {
			ContentView().environment(locationDataManager)
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
