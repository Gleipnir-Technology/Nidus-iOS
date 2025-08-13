import MijickCamera
import OSLog
import SwiftUI

/*
 Our own custom camera view with controls.
 */
struct CameraView: View {
	var controller: CameraController
	// The controller that we'll trigger when the user does stuff
	let toDismiss: () -> Void
	// Function to dismiss this control

	init(
		controller: CameraController,
		toDismiss: @escaping () -> Void
	) {
		self.controller = controller
		self.toDismiss = toDismiss
	}

	var body: some View {
		MCamera()
			.onError { error in
				Logger.foreground.error("Camera error: \(error)")
			}
			.onImageCaptured { image, camera in
				controller.saveImage(image)
				camera.reopenCameraScreen()
			}
			.setCloseMCameraAction {
				toDismiss()
			}
			.onVideoCaptured { url, camera in
				controller.saveVideo(url)
				camera.reopenCameraScreen()
			}.startSession()
		//.navigationBarBackButtonHidden(true)
	}
}
