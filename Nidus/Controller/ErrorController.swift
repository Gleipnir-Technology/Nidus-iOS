import SwiftUI

@Observable
class ErrorController {
	var message: String = ""

	func onError(_ error: Error) {
		message = "UI level error: \(error)"
	}
}
