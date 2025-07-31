import SwiftUI

/*
 A button that can do either a long press or a short press and has actions for both
 */
struct ButtonWithLongPress<Content: View>: View {
	let actionLong: () -> Void
	let actionShort: () -> Void
	let isAnimated: Bool
	@ViewBuilder let label: Content

	var isOn: Bool = true

	init(
		actionLong: @escaping () -> Void,
		actionShort: @escaping () -> Void,
		isAnimated: Bool = false,
		@ViewBuilder label: () -> Content
	) {
		self.actionLong = actionLong
		self.actionShort = actionShort
		self.isAnimated = isAnimated
		self.label = label()
	}

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
			.animation(
				isAnimated
					? .easeInOut(duration: 0.5).repeatForever(
						autoreverses: true
					) : .default
			) { content in
				content.scaleEffect(isAnimated ? 1.1 : 1.0)
			}
	}
}
