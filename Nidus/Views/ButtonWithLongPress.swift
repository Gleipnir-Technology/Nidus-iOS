import SwiftUI

/*
 A button that can do either a long press or a short press and has actions for both
 */
struct ButtonWithLongPress<Content: View>: View {
	let actionLong: () -> Void
	let actionShort: () -> Void
	@ViewBuilder let label: Content

	var isOn: Bool = true

	@GestureState private var isDragging = false

	var body: some View {
		Circle()
			.stroke(
				style: StrokeStyle.init(
					lineWidth: 1,
					lineCap: .round,
					lineJoin: .round
				)
			)
			.frame(width: 100, height: 100)
			.overlay(label)
			.onTapGesture(perform: actionShort)
			.onLongPressGesture(perform: actionLong)
	}
}
