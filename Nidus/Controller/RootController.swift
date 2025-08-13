import MapKit
import OSLog
import SwiftUI

/*
 Root controller for the entire application
 */
@Observable
class RootController {
	var audioPlayback = AudioPlaybackController()
	var audioRecording = AudioRecordingController()
	var database = DatabaseController()
	var camera = CameraController()
	var error = ErrorController()
	var network = NetworkController()
	var notes = NotesController()
	var region = RegionController()
	var settings = SettingsController()
	var toast = ToastController()

	// MARK - public interface
	func onAppear() {
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
		audioRecording.onRecordingSave { recording in
			do {
				try self.notes.saveAudioNote(recording)
			}
			catch {
				self.error.message = "Failed to save recording: \(error)"
			}
		}
		camera.onPictureSave { picture in
			do {
				let location = self.region.breadcrumb.userCell
				Logger.background.info(
					"Saving picture with location \(String(location ?? 0, radix: 16))"
				)
				try self.notes.savePictureNote(picture, location)
			}
			catch {
				self.error.message = "Failed to save picture: \(error)"
			}
		}
		region.onAppear()
		region.onLocationUpdated { location in
			self.audioRecording.onLocationUpdated(location)
		}
		region.onRegionChange(onRegionChange)
	}

	func onInit() {
		notes.startLoad(database: database, network: network)
		settings.load()
		region.current = settings.model.region
	}

	func onRegionChange(r: MKCoordinateRegion) {
		notes.onRegionChange(r)
		notes.startUpdateCluster()
		settings.saveCurrentRegion(r)
	}

}

class RootControllerPreview: RootController {
	init(
		audioRecording: AudioRecordingControllerPreview = AudioRecordingControllerPreview(),
		notes: NotesControllerPreview = NotesControllerPreview()
	) {
		super.init()
		self.audioRecording = audioRecording
		self.notes = notes
	}
}
