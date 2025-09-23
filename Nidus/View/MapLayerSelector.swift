import OSLog
import SwiftUI

struct MapLayerSelector: View {
	var onOverlaySelectionChange: (Set<MapOverlay>) -> Void
	// Controls whether the layer icons are visible
	@State private var showingLayerOptions = false

	// Track which layers are enabled
	@State private var showNotes = true
	@State private var showServiceRequests = true
	@State private var showSources = true
	@State private var showTraps = true

	func handleOverlaySelectionChange() {
		var selectedOverlays: Set<MapOverlay> = []
		if showNotes {
			selectedOverlays.insert(.Note)
		}
		if showServiceRequests {
			selectedOverlays.insert(.ServiceRequest)
		}
		if showSources {
			selectedOverlays.insert(.MosquitoSource)
		}
		if showTraps {
			selectedOverlays.insert(.MosquitoTrap)
		}
		onOverlaySelectionChange(selectedOverlays)
	}

	var body: some View {
		ZStack(alignment: .bottom) {
			// Layer buttons container - positioned above the main button
			if showingLayerOptions {
				VStack(spacing: 10) {
					// Mosquito Source layer
					Button(action: {
						showSources.toggle()
						handleOverlaySelectionChange()
					}) {
						ZStack {
							RoundedRectangle(cornerRadius: 12)
								.fill(
									showSources
										? Color.red
										: Color.secondary
								)  // Color for traps
								.frame(width: 50, height: 50)

							Image("mosquito.sideview")
								.foregroundColor(.white)
								.font(.title2)
						}
					}

					// Mosquito Trap Layer
					Button(action: {
						showTraps.toggle()
						handleOverlaySelectionChange()
					}) {
						ZStack {
							RoundedRectangle(cornerRadius: 12)
								.fill(
									showTraps
										? Color.orange
										: Color.secondary
								)
								.frame(width: 50, height: 50)

							Image(
								systemName:
									"homepod.mini.arrow.forward"
							)
							.foregroundColor(.white)
							.font(.title2)
						}
					}

					// Notes layer
					Button(action: {
						showNotes.toggle()
						handleOverlaySelectionChange()
					}) {
						ZStack {
							RoundedRectangle(cornerRadius: 12)
								.fill(
									showNotes
										? Color.blue
										: Color.secondary
								)  // Color for sources
								.frame(width: 50, height: 50)

							Image(systemName: "note.text")
								.foregroundColor(.white)
								.font(.title2)
						}
					}

					Button(action: {
						showServiceRequests.toggle()
						handleOverlaySelectionChange()
					}) {
						ZStack {
							RoundedRectangle(cornerRadius: 12)
								.fill(
									showNotes
										? Color.green
										: Color.secondary
								)  // Color for sources
								.frame(width: 50, height: 50)

							Image(systemName: "person.wave.2.fill")
								.foregroundColor(.white)
								.font(.title2)
						}
					}

					// Spacer to ensure proper positioning above main button
					Spacer().frame(height: 60)
				}
				.transition(.opacity)
			}

			// Main toggle button - always at the bottom
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
		VStack {
			Spacer()  // Push to bottom
			HStack {
				MapLayerSelector(onOverlaySelectionChange: { _ in })
					.padding()
				Spacer()  // Push to left
			}
		}
	}
}
