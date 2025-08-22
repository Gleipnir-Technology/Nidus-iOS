import Sentry
import SwiftData
import SwiftUI
import UIKit

@main
@MainActor
struct NidusApp: App {
	@UIApplicationDelegateAdaptor private var appDelegate: NidusAppDelegate

	var body: some Scene {
		WindowGroup {
			RootView(controller: RootController())
		}
	}
}

class NidusAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
	var backgroundCompletionHandler: (() -> Void)?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		SentrySDK.start { options in
			options.dsn =
				"https://9412221dde2447439c6e931fcfebc391@glitchtip.gleipnir.technology/1"
			options.debug = true
			options.tracesSampleRate = 1.0
		}
		return true
	}

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
