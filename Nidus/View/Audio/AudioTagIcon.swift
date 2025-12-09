import SwiftUI

struct AudioTagIcon: View {
	let color: Color
	let systemName: String

	init(_ systemName: String, color: Color = .gray) {
		self.color = color
		self.systemName = systemName
	}

	var body: some View {
		ZStack {
			Circle().stroke(color, lineWidth: 3).frame(width: 30, height: 30)
			Image(systemName: systemName)
		}.padding(3)
	}
}

struct AudioTagIconMajor: View {
	let color: Color
	let letter: String

	init(_ letter: String, color: Color = .gray) {
		self.color = color
		self.letter = letter
	}
	var body: some View {
		ZStack {
			Circle().stroke(color, lineWidth: 3).frame(width: 40, height: 40)
			Text(letter)
		}.padding(3)
	}
}
