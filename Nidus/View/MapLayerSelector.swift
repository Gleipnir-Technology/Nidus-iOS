import OSLog
import SwiftUI

struct MapLayerSelector: View {
	// Controls whether the layer icons are visible
	@State private var showingLayerOptions = false

	// Track which layers are enabled
	@State private var showSources = true
	@State private var showTreatments = true
	@State private var showTraps = true

	var body: some View {
		VStack {
			// Sources layer button (visible when expanded)
			if showingLayerOptions {
				Button(action: {
					showSources.toggle()
				}) {
					ZStack {
						RoundedRectangle(cornerRadius: 12)
							.fill(Color.blue)  // Color for sources
							.frame(width: 50, height: 50)
							.opacity(showSources ? 1.0 : 0.5)

						Image(systemName: "drop.fill")
							.foregroundColor(.white)
							.font(.title2)
					}
				}
				.transition(.move(edge: .top).combined(with: .opacity))

				// Treatments layer button
				Button(action: {
					showTreatments.toggle()
				}) {
					ZStack {
						RoundedRectangle(cornerRadius: 12)
							.fill(Color.green)  // Color for treatments
							.frame(width: 50, height: 50)
							.opacity(showTreatments ? 1.0 : 0.5)

						Image(systemName: "spray.fill")
							.foregroundColor(.white)
							.font(.title2)
					}
				}
				.transition(.move(edge: .top).combined(with: .opacity))

				// Traps layer button
				Button(action: {
					showTraps.toggle()
				}) {
					ZStack {
						RoundedRectangle(cornerRadius: 12)
							.fill(Color.red)  // Color for traps
							.frame(width: 50, height: 50)
							.opacity(showTraps ? 1.0 : 0.5)

						Image(systemName: "target")
							.foregroundColor(.white)
							.font(.title2)
					}
				}
				.transition(.move(edge: .top).combined(with: .opacity))
			}

			// Main toggle button
			Button(action: {
				withAnimation(.spring()) {
					showingLayerOptions.toggle()
				}
			}) {
				ZStack {
					RoundedRectangle(cornerRadius: 12)
						.fill(Color.white)
						.frame(width: 50, height: 50)
						.shadow(radius: 2)

					Image(systemName: "square.3.layers.3d")
						.foregroundColor(Color.primary)
						.font(.title)

					// Small indicator that shows if expanded
					if showingLayerOptions {
						RoundedRectangle(cornerRadius: 2)
							.fill(Color.blue)
							.frame(width: 15, height: 3)
							.offset(y: 15)
					}
				}
			}
		}
		.padding(8)
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.white.opacity(0.8))
				.shadow(radius: 2)
				.opacity(showingLayerOptions ? 1 : 0)
		)
		.animation(.spring(), value: showingLayerOptions)
	}
}

#Preview() {
	ZStack {
		Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)  // Simulate map background
		MapLayerSelector()
			.padding()
	}
}
