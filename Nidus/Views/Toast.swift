//
//  Toast.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/28/25.
//

import SwiftUI

struct Toast: ViewModifier {
	// these correspond to Android values f
	// or DURATION_SHORT and DURATION_LONG
	static let short: TimeInterval = 2
	static let long: TimeInterval = 3.5

	let message: String
	@Binding var isShowing: Bool
	let config: Config

	func body(content: Content) -> some View {
		ZStack {
			content
			toastView
		}
	}

	private var toastView: some View {
		VStack {
			Spacer()
			if isShowing {
				Group {
					Text(message)
						.multilineTextAlignment(.center)
						.foregroundColor(config.textColor)
						.font(config.font)
						.padding(8)
				}
				.background(config.backgroundColor)
				.cornerRadius(8)
				.onTapGesture {
					isShowing = false
				}
				.onAppear {
					DispatchQueue.main.asyncAfter(
						deadline: .now() + config.duration
					) {
						isShowing = false
					}
				}
			}
		}
		.padding(.horizontal, 16)
		.padding(.bottom, 18)
		.animation(config.animation, value: isShowing)
		.transition(config.transition)
	}

	struct Config {
		let textColor: Color
		let font: Font
		let backgroundColor: Color
		let duration: TimeInterval
		let transition: AnyTransition
		let animation: Animation

		init(
			textColor: Color = .white,
			font: Font = .system(size: 14),
			backgroundColor: Color = .black.opacity(0.588),
			duration: TimeInterval = Toast.short,
			transition: AnyTransition = .opacity,
			animation: Animation = .linear(duration: 0.3)
		) {
			self.textColor = textColor
			self.font = font
			self.backgroundColor = backgroundColor
			self.duration = duration
			self.transition = transition
			self.animation = animation
		}
	}
}

extension View {
	func toast(
		message: String,
		isShowing: Binding<Bool>,
		config: Toast.Config
	) -> some View {
		self.modifier(
			Toast(
				message: message,
				isShowing: isShowing,
				config: config
			)
		)
	}

	func toast(
		message: String,
		isShowing: Binding<Bool>,
		duration: TimeInterval
	) -> some View {
		self.modifier(
			Toast(
				message: message,
				isShowing: isShowing,
				config: .init(duration: duration)
			)
		)
	}
}

struct ToastTest: View {
	@State private var showToast = false

	var body: some View {
		NavigationView {
			List(1..<100) { index in
				Text("Row \(index)")
			}
			.toast(
				message:
					"Current time:\n\(Date().formatted(date: .complete, time: .complete))",
				isShowing: $showToast,
				duration: Toast.short
			)
			.navigationBarTitle("Toast Testing")
			.navigationBarItems(
				leading: Button("Show") {
					showToast = true
				}
			)
		}
	}
}
