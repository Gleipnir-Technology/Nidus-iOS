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

	func noteAudioUpdate(_ note: AudioNote, transcription: String) {
		do {
			try database.service.noteAudioUpdate(note, transcription: transcription)
		}
		catch {
			handleError(error)
		}
	}
	// MARK - public interface
	func onAppear() {
		audioRecording.onRecordingSave { recording in
			Task {
				do {
					try self.database.service.insertAudioNote(recording)
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
					self.handleError(error, "Failed to save audio recording")
				}
			}
		}
		camera.onPictureSave { picture in
			do {
				let note = try self.savePictureNote(
					picture,
					self.region.breadcrumb.userCell
				)
				Task {
					do {
						try await self.network.uploadNotePicture(note)
					}
					catch {
						self.handleError(error, "Failed to upload note")
					}
				}
			}
			catch {
				self.handleError(error, "Failed to save picture note")
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
			try database.connect()
			settings.load()
			region.current = settings.model.region
			network.onSettingsChanged(settings.model, database)
		}
		catch {
			handleError(error, "Failed in onInit")
		}
	}

	func savePictureNote(_ picture: Photo, _ location: H3Cell?) throws -> PictureNote {
		let uuid = UUID()
		let url = PictureNote.url(uuid)
		try picture.data.write(to: url)
		Logger.foreground.info("Saved photo file to \(url)")
		let note = PictureNote(
			id: uuid,
			cell: location,
			created: Date.now
		)
		try database.service.insertPictureNote(note)
		Logger.foreground.info("Saved picture \(uuid)")
		return note
	}

	func saveSettings(password: String, url: String, username: String) {
		settings.saveSync(password: password, url: url, username: username)
		network.onSettingsChanged(settings.model, database)
	}

	func onRegionChange(r: MKCoordinateRegion) {
		calculateNotesToShow(r)

		settings.saveCurrentRegion(r)
	}

	// MARK - private functions
	private func calculateNotesToShow(_ region: MKCoordinateRegion) {
		Task {
			do {
				let notes = try database.service.notesByRegion(region)
				self.notes.showNotes(
					mapAnnotations: notes.map { $0.value.mapAnnotation },
					notes: notes,
					noteOverviews: notes.map { $0.value.overview }
				)
			}
			catch {
				handleError(error, "Failed to calculate notes")
			}
		}
	}

	private func handleError(_ error: Error, _ message: String = "") {
		SentrySDK.capture(error: error)
		Logger.background.error("Unhandled error: \(message) \(error)")
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
