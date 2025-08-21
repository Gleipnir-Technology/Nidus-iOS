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

			/*
			ProgressView(value: controller.backgroundNetworkProgress)
				.progressViewStyle(.circular)
				.font(.title2)
             */
			Circle()
				.trim(from: 0, to: CGFloat(controller.backgroundNetworkProgress))
				.stroke(Color.blue, lineWidth: 4)
				.rotationEffect(Angle(degrees: -90))
				.frame(width: 40, height: 40)
		}
	}
}
#Preview {
	NetworkStatusView(
		controller: NetworkControllerPreview(
			backgroundNetworkProgress: 0.45,
			backgroundNetworkState: .downloading
		)
	).background(Color.black)
}
