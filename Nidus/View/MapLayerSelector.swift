import OSLog
import SwiftUI

/// A small overlay view that shows what the network is currently doing, including downloading items
/// saving items, or waiting for changes.
struct MapLayerSelector: View {
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.white)
				.frame(width: 50, height: 50)
			Image(systemName: "square.3.layers.3d").foregroundColor(Color.primary).font(
				.title
			)
		}
	}
}

private func mapLayerSelectorPreview() -> some View {
	MapLayerSelector().background(Color.black)
}

#Preview() {
	MapLayerSelector()
}
