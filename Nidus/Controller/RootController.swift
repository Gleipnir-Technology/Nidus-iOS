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
				Logger.background.error("Failed to calculate notes: \(error)")
			}
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
				let uuid = UUID()
				let url = try! FileManager.default.url(
					for: .applicationSupportDirectory,
					in: .userDomainMask,
					appropriateFor: nil,
					create: true
				).appendingPathComponent("\(uuid).photo")
				try picture.data.write(to: url)
				let note = PictureNote(
					id: uuid,
					cell: location,
					created: Date.now
				)
				try self.database.service.insertPictureNote(note)
				Logger.foreground.info("Saved picture \(uuid)")
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
			try database.connect()
			settings.onChanged { update in
				self.network.onSettingsChanged(update)
			}
			settings.load()
			network.onInit()
			region.current = settings.model.region
			startBackgroundTasks()
		}
		catch {
			SentrySDK.capture(error: error)
			Logger.foreground.error("Failed to initialize the app: \(error)")
		}
	}

	func savePictureNote(_ picture: Photo, _ location: H3Cell?) throws -> PictureNote {
		let uuid = UUID()
		let url = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		).appendingPathComponent("\(uuid).photo")
		try picture.data.write(to: url)
		let note = PictureNote(
			id: uuid,
			cell: location,
			created: Date.now
		)
		try database.service.insertPictureNote(note)
		Logger.foreground.info("Saved picture \(uuid)")
		return note
	}

	func onRegionChange(r: MKCoordinateRegion) {
		calculateNotesToShow(r)

		settings.saveCurrentRegion(r)
	}

	// MARK - private functions

	/// Kick off the different background tasks we should be doing
	private func startBackgroundTasks() {
		Task {
			await network.downloadNotes(database)
			await network.uploadAudioNotes(database)
			await network.uploadPictureNotes(database)
		}
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
