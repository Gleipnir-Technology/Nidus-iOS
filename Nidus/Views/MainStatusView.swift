import SwiftUI

struct MainStatusView: View {
	var backgroundNetworkState: BackgroundNetworkState
	var backgroundNetworkProgress: Double
	var errorMessage: String?

	var body: some View {
		switch backgroundNetworkState {
		case .downloading:
			ProgressView(
				"Downloading data",
				value: backgroundNetworkProgress
			).frame(maxWidth: 300)
		case .error:
			Text("Error downloading data: \(errorMessage ?? "")")
		case .idle:
			EmptyView()
		case .loggingIn:
			Text("Logging in...")
		case .notConfigured:
			Text("Configure sync in settings")
		case .savingData:
			ProgressView(
				"Saving data",
				value: backgroundNetworkProgress
			).frame(maxWidth: 300)
		case .uploadingChanges:
			ProgressView(
				"Uploading",
				value: backgroundNetworkProgress
			).frame(maxWidth: 300)
		}
	}
}
