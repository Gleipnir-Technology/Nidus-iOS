import MapKit
import SwiftUI

/*
 Root controller for the entire application
 */
@Observable
class RootController {
	var audio = AudioController()
	var camera = CameraController()
	var error = ErrorController()
	var network = NetworkController()
	var notes = NotesController()
	var region = RegionController()
	var settings = SettingsController()
	var toast = ToastController()

	// MARK - public interface
	func onAppear() {
		settings.load()
		settings.onChanged { update in
			Task {
				do {
					try await self.network.service.connect(update)
				}
				catch {
					self.error.onError(error)
				}
			}
		}
		region.onAppear()
	}

	func onRegionChange(r: MKCoordinateRegion) {
		region.onRegionChange(r)
		notes.calculateNotesToShow()
		notes.startUpdateCluster()
		settings.saveCurrentRegion(r)
	}

}

class RootControllerPreview: RootController {
	init(audio: AudioControllerPreview = AudioControllerPreview()) {
		super.init()

	}
}
