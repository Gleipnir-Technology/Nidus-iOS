import MijickCamera
import SwiftUI

/*
 Our own custom camera view with controls.
 */
struct CameraView: View {
	@State var controller: CameraController
	// The controller that we'll trigger when the user does stuff
	let toDismiss: () -> Void
	// Function to dismiss this control

	let forPreview: Bool
	// Whether or not we're showing this control as part of a preview. Helps to avoid crashing Previews.

	init(
		controller: CameraController,
		forPreview: Bool = false,
		toDismiss: @escaping () -> Void
	) {
		self.controller = controller
		self.forPreview = forPreview
		self.toDismiss = toDismiss
	}

	var body: some View {
		if forPreview {
			Spacer()
			Image(uiImage: UIImage(named: "camera-placeholder")!).resizable()
				.aspectRatio(contentMode: .fit).background(
					Color.cyan.opacity(0.4)
				)
		}
		else {
			MCamera()
				.setCameraScreen(
					DefaultCameraScreenBuilder(
						hasFlashButton: true,
						hasLightButton: true
					)
				)
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
				.navigationBarBackButtonHidden(true)
		}
	}
}

struct CameraControls: View {
	var body: some View {
		HStack {
			Image(systemName: "photo").font(.system(size: 64, weight: .regular))
				.padding(20)
			Spacer()
			Image(systemName: "camera.aperture").font(
				.system(size: 82, weight: .regular)
			)
			Spacer()
			Image(systemName: "record.circle").font(.system(size: 64, weight: .regular))
				.padding(20)
		}
	}
}

struct CameraView_Previews: PreviewProvider {
	@State static var controller: CameraController = CameraControllerPreview()
	static var previews: some View {
		CameraView(controller: controller, forPreview: true, toDismiss: {})
	}
}
