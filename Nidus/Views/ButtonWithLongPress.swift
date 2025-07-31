import SwiftUI

struct ButtonWithLongPress<Content: View>: View {
	let actionLong: () -> Void
	let actionShort: () -> Void
	@ViewBuilder let label: Content

	var isOn: Bool = true

	@GestureState private var isDragging = false

	var body: some View {
		Circle()
			.fill(isOn ? Color.green : Color.gray)
			.overlay(label)
			.onTapGesture(perform: actionShort)
			.onLongPressGesture(perform: actionLong)
	}
}
