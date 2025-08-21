import SwiftUI

/// A small overlay view that shows what the network is currently doing, including downloading items
/// saving items, or waiting for changes.
struct NetworkStatusView: View {
	@State var controller: NetworkController
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.white)
				.frame(width: 50, height: 50)

			ProgressView(value: controller.backgroundNetworkProgress)
				.progressViewStyle(.circular)
				.font(.title2)
		}
	}
}
