import SwiftUI

/// A small overlay view that shows what the network is currently doing, including downloading items
/// saving items, or waiting for changes.
struct NetworkStatusView: View {
	@State var controller: NetworkController
	var body: some View {
		if controller.backgroundNetworkState == .idle {
			EmptyView()
		}
		else {
			ZStack {
				RoundedRectangle(cornerRadius: 12)
					.fill(Color.white)
					.frame(width: 50, height: 50)

				/*
                 ProgressView(value: controller.backgroundNetworkProgress)
                 .progressViewStyle(.circular)
                 .font(.title2)
                 */
				switch controller.backgroundNetworkState {
				case .downloading:
					ProgressCircle(
						progress: controller.backgroundNetworkProgress,
						color: Color.blue
					)
				case .error:
					Image(systemName: "nosign.app").foregroundStyle(.red)
				case .idle:
					EmptyView()
				case .loggingIn:
					Image(systemName: "lock.rotation").foregroundStyle(.green)
				case .notConfigured:
					Image(systemName: "questionmark.key.filled")
						.foregroundStyle(.gray)
				case .savingData:
					ProgressCircle(
						progress: controller.backgroundNetworkProgress,
						color: Color.green
					)
				case .uploadingChanges:
					ProgressCircle(
						progress: controller.backgroundNetworkProgress,
						color: Color.cyan
					)
				}
			}
		}
	}
}

struct ProgressCircle: View {
	@State var progress: Double = 0
	@State var color: Color = .black

	var body: some View {
		Circle()
			.trim(from: 0, to: CGFloat(progress))
			.stroke(color, lineWidth: 4)
			.rotationEffect(Angle(degrees: -90))
			.frame(width: 40, height: 40)
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
