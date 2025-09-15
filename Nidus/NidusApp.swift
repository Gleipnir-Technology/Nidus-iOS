import OSLog
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
			let store = RootStore()
			RootView(controller: RootController(store: store))
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
			options.debug = false
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

	func application(
		_ application: UIApplication,
		supportedInterfaceOrientationsFor window: UIWindow?
	) -> UIInterfaceOrientationMask {
		return .portrait
	}

}

func CaptureError(_ error: Error, _ msg: String = "unknown") {
	Logger.background.error("Unhandled Nidus error in \(msg): \(error)")
	SentrySDK.capture(error: error)
}

func TrackTime(_ label: String, block: () -> Void) {
	let start = DispatchTime.now()
	block()
	let end = DispatchTime.now()
	let nanoseconds = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)
	if nanoseconds > 1_000_000_000 {
		let seconds = nanoseconds / 1_000_000_000
		Logger.background.debug("\(label): \(seconds) seconds")
	}
	else if nanoseconds > 1_000_000 {
		let milliseconds = nanoseconds / 1_000_000
		Logger.background.debug("\(label): \(milliseconds) ms")
	}
	else {
		Logger.background.debug("\(label): \(nanoseconds) nanos")
	}
}
