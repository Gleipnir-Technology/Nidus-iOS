import SwiftUI

struct ContentView: View {
	@State private var isOn = false
	@State private var showingDetailPane = false
	@State private var dragOffset: CGFloat = 0

	let detailPaneHeight: CGFloat = 300

	var body: some View {
		ZStack {
			// Main content
			VStack {
				Spacer()
				CustomButton(
					isOn: $isOn,
					showingDetailPane: $showingDetailPane,
					dragOffset: $dragOffset
				)
				.frame(width: 100, height: 100)

			}
			.padding()

			// Detail pane
			DetailPane()
				.frame(maxWidth: .infinity)
				.frame(height: detailPaneHeight)
				.background(Color.white)
				.cornerRadius(20)
				.shadow(radius: 10)
				.offset(
					y: showingDetailPane
						? UIScreen.main.bounds.height - detailPaneHeight
							- dragOffset : UIScreen.main.bounds.height
				)
				.animation(.spring(), value: showingDetailPane)
				.animation(.spring(), value: dragOffset)
		}
	}
}

struct CustomButton: View {
	@Binding var isOn: Bool
	@Binding var showingDetailPane: Bool
	@Binding var dragOffset: CGFloat

	@GestureState private var isDragging = false

	var body: some View {
		Circle()
			.fill(isOn ? Color.green : Color.gray)
			.overlay(
				Image(systemName: "microphone")
					.foregroundColor(isOn ? .primary : .secondary)
					.font(.system(size: 30))
			)
			.gesture(
				// Tap gesture
				TapGesture()
					.onEnded { _ in
						isOn.toggle()
					}
			)
			.gesture(
				LongPressGesture()
					.onEnded { value in
						showingDetailPane = true
						dragOffset = 300
					}
			)
	}
}

struct DetailPane: View {
	var body: some View {
		VStack(spacing: 20) {
			Rectangle()
				.fill(Color.gray.opacity(0.3))
				.frame(width: 40, height: 5)
				.cornerRadius(3)
				.padding(.top, 10)

			Text("Process Details")
				.font(.headline)

			// Add your process details here
			VStack(alignment: .leading, spacing: 10) {
				Text("Status: Running")
				Text("Time Elapsed: 2h 30m")
				Text("Progress: 75%")

				ProgressView(value: 0.75)
					.padding(.horizontal)
			}
			.padding()

			Spacer()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
