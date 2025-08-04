import SwiftUI

@Observable
class NetworkController {
	// TODO: make this private eventually
	var service: NetworkService = NetworkService()

	var backgroundNetworkProgress: Double = 0.0
	var backgroundNetworkState: BackgroundNetworkState = .idle

	// MARK - public interface
	func createBackgroundNetworkManager() {
	}

}
