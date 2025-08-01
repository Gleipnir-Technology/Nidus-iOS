import SwiftUI

struct CodeBlockView: View {
	var code: String
	var body: some View {
		ScrollView(.horizontal) {
			Text(attributedString(for: code))
				.font(.system(.body, design: .monospaced))
				.padding()
				.background(Color.black)
				.cornerRadius(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color.gray, lineWidth: 1)
				)
				.shadow(radius: 2)
				.multilineTextAlignment(.leading)
				.foregroundColor(.white)
		}
		.padding(.horizontal)
	}  // Helper function to create an AttributedString with simulated syntax highlighting
	func attributedString(for code: String) -> AttributedString {
		var attributedString = AttributedString(code)  // Add syntax highlighting for Swift keywords, strings, etc.
		let keywords = ["let", "var", "if", "else", "struct", "func", "return"]
		let stringPattern = "\\.\\*\\?"
		for keyword in keywords {
			let ranges = code.ranges(of: keyword)
			for range in ranges {
				if let attributedRange = Range(
					NSRange(range, in: code),
					in: attributedString
				) {
					attributedString[attributedRange].foregroundColor = .blue  // Swift keywords in blue
				}
			}
		}  // Highlight strings (enclosed in quotation marks)
		if let regex = try? NSRegularExpression(pattern: stringPattern) {
			let matches = regex.matches(
				in: code,
				range: NSRange(code.startIndex..., in: code)
			)
			for match in matches {
				if let stringRange = Range(match.range, in: code),
					let attributedRange = Range(
						NSRange(stringRange, in: code),
						in: attributedString
					)
				{
					attributedString[attributedRange].foregroundColor = .green  // Strings in green
				}
			}
		}
		return attributedString
	}
}

extension String {
	/// Helper to find all ranges of a substring within a string
	func ranges(of substring: String) -> [Range<String.Index>] {
		var result: [Range<String.Index>] = []
		var startIndex = self.startIndex
		while startIndex < self.endIndex,
			let range = self.range(of: substring, range: startIndex..<self.endIndex)
		{
			result.append(range)
			startIndex = range.upperBound
		}
		return result
	}
}
struct SwiftUIView: View {
	var body: some View {
		VStack {
			Text("Code Block Example")
				.font(.title)
				.padding()

			CodeBlockView(
				code: """
					struct Person {
					    let name: String
					    var age: Int                func greet() {
					        print("Hello, \\\\\\\\(name)!")
					    }
					}
					"""
			)
			Spacer()
		}
		.padding()
	}
}
#Preview {
	SwiftUIView()
}
