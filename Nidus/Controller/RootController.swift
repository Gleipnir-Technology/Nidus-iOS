import MapKit
import OSLog
import Sentry
import SwiftUI

/*
 Root controller for the entire application
 */
@MainActor
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
		audioRecording.onRecordingSave { recording in
			Task {
				do {
					try await self.notes.saveAudioNote(recording)
					Logger.background.info(
						"Saved recording \(recording.id) to database"
					)
					try await self.network.uploadNoteAudio(recording)
					Logger.background.info(
						"Uploaded recording \(recording.id) to server"
					)
					try self.database.service.audioUploaded(recording.id)
				}
				catch {
					self.error.message = "Failed to save recording: \(error)"
				}
			}
		}
		camera.onPictureSave { picture in
			do {
				let location = self.region.breadcrumb.userCell
				Logger.background.info(
					"Saving picture with location \(String(location ?? 0, radix: 16))"
				)
				let note = try self.notes.savePictureNote(picture, location)
				Task {
					do {
						try await self.network.uploadNotePicture(note)
					}
					catch {
						SentrySDK.capture(error: error)
						Logger.background.error(
							"Failed to upload picture: \(error)"
						)
					}
				}
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
		do {
			throw DatabaseError.notConnected
		}
		catch {
			SentrySDK.capture(error: error)
		}
		settings.onChanged { update in
			self.network.onSettingsChanged(update)
		}
		settings.load()
		region.current = settings.model.region
		network.notes = notes
		Task {
			do {
				try await notes.Load(database: database, network: network)
				await network.Load()
			}
			catch {
				Logger.background.error("Faild in root controller onInit: \(error)")
			}
		}
	}

	func onRegionChange(r: MKCoordinateRegion) {
		notes.onRegionChange(r)
		settings.saveCurrentRegion(r)
	}

}

class RootControllerPreview: RootController {
	init(
		audioRecording: AudioRecordingControllerPreview = AudioRecordingControllerPreview(),
		network: NetworkControllerPreview = NetworkControllerPreview(),
		notes: NotesControllerPreview = NotesControllerPreview()
	) {
		super.init()
		self.audioRecording = audioRecording
		self.network = network
		self.notes = notes
	}

	override func onAppear() {

	}
	override func onInit() {

	}
}
