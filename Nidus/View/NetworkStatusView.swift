import OSLog
import SwiftUI

/// A small overlay view that shows what the network is currently doing, including downloading items
/// saving items, or waiting for changes.
struct NetworkStatusView: View {
	var progress: Double
	var state: BackgroundNetworkState
	var body: some View {
		if state == .idle {
			EmptyView()
		}
		else {
			ZStack {
				RoundedRectangle(cornerRadius: 12)
					.fill(Color.white)
					.frame(width: 50, height: 50)
				switch state {
				case .downloading:
					ProgressCircle(
						progress: progress,
						color: Color.blue
					)
				case .error:
					Image(systemName: "nosign.app").foregroundColor(.red).font(
						.title
					)
				case .idle:
					EmptyView()
				case .loggingIn:
					Image(systemName: "lock.rotation").foregroundColor(.green)
						.font(.title)
				case .notConfigured:
					Image(systemName: "questionmark.key.filled")
						.foregroundColor(.gray).font(.title)
				case .savingData:
					ProgressCircle(
						progress: progress,
						color: Color.green
					)
				case .uploadingChanges:
					ProgressCircle(
						progress: progress,
						color: Color.cyan
					)
				}
				//Text("\((progress * 100).rounded(.down))%")
			}
		}
	}
}

struct ProgressCircle: View {
	var progress: Double = 0
	var color: Color = .black

	var body: some View {
		ZStack {
			Circle()
				.trim(from: 0, to: progress)
				.stroke(color, lineWidth: 5)
				.rotationEffect(Angle(degrees: -90))
				.frame(width: 40, height: 40)
		}
	}
}

private func statusPreview(_ progress: Double, _ state: BackgroundNetworkState) -> some View {
	NetworkStatusView(
		progress: 0.1,
		state: state
	).background(Color.black)
}

#Preview("downloading") {
	statusPreview(0.45, .downloading)
}

#Preview("error") {
	statusPreview(0.55, .error)
}

#Preview("loggingIn") {
	statusPreview(0.25, .loggingIn)
}

#Preview("notConfigured") {
	statusPreview(0.35, .notConfigured)
}

#Preview("saving") {
	statusPreview(0.75, .savingData)
}
