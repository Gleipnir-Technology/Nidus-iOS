import SwiftData
import SwiftUI
import UIKit

@main
@MainActor
struct NidusApp: App {
	@State private var model = ModelNidus()
	@UIApplicationDelegateAdaptor private var appDelegate: NidusAppDelegate

	var body: some Scene {
		WindowGroup {
			RootView(
				model: model,
				onAppear: model.createBackgroundNetworkManager
			)
		}
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
