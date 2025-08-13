import SwiftUI

@Observable
class CameraController {
	var callbacks: [(UIImage) -> Void] = []
	func onPictureSave(_ callback: @escaping (UIImage) -> Void) {
		callbacks.append(callback)
	}
	func saveImage(_ image: UIImage) {
		handlePictureSave(image)
	}

	func saveVideo(_ url: URL) {

	}

	private func handlePictureSave(_ image: UIImage) {
		callbacks.forEach { $0(image) }
	}
}

class CameraControllerPreview: CameraController {

}
