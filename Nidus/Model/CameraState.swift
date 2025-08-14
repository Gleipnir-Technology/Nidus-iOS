import Foundation
import os

struct CameraState: Codable {

	var isLivePhotoEnabled = true {
		didSet { save() }
	}

	var qualityPrioritization = QualityPrioritization.quality {
		didSet { save() }
	}

	var isVideoHDRSupported = true {
		didSet { save() }
	}

	var isVideoHDREnabled = true {
		didSet { save() }
	}

	var captureMode = CaptureMode.photo {
		didSet { save() }
	}

	private func save() {
		Task {
			do {
				try await AVCamCaptureIntent.updateAppContext(self)
			}
			catch {
				os.Logger().debug(
					"Unable to update intent context: \(error.localizedDescription)"
				)
			}
		}
	}

	static var current: CameraState {
		get async {
			do {
				if let context = try await AVCamCaptureIntent.appContext {
					return context
				}
			}
			catch {
				os.Logger().debug(
					"Unable to fetch intent context: \(error.localizedDescription)"
				)
			}
			return CameraState()
		}
	}
}
