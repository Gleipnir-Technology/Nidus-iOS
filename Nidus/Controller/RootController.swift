import MapKit
import OSLog
import Sentry
import SwiftUI

/*
 Root controller for the entire application
 */
class RootController {
	let audioPlayback: AudioPlaybackController
	let audioRecording: AudioRecordingController
	let database: DatabaseController
	let camera: CameraController
	let error: ErrorController
	let network: NetworkController
	let notes: NotesController
	let region: RegionController
	let settings: SettingsController
	let toast: ToastController

	let store: RootStore
	@MainActor
	init(
		audioRecording: AudioRecordingController? = nil,
		network: NetworkController = NetworkController(),
		notes: NotesController = NotesController(),
		store: RootStore
	) {
		audioPlayback = AudioPlaybackController(store.audioPlayback)
		self.audioRecording =
			audioRecording ?? AudioRecordingController(store.audioRecording)
		database = DatabaseController()
		camera = CameraController()
		error = ErrorController()
		self.network = network
		self.notes = notes
		region = RegionController()
		settings = SettingsController()
		self.store = store
		toast = ToastController()
	}

	func noteAudioUpdate(_ note: AudioNote, transcription: String) {
		do {
			try database.service.noteAudioUpdate(note, transcription: transcription)
			// This restores the notes in our collection with the new update
			// There's definitely a more-efficient way to do this
			calculateNotesToShow(region.current)
			Task {
				guard let newNote = try database.service.noteAudio(note.id) else {
					Logger.background.info(
						"Somehow failed to get a note after updating it, there's a logic error here."
					)
					return
				}
				do {
					try await network.uploadNoteAudio(newNote)
					try database.service.audioUploaded(newNote.id)
				}
				catch {
					self.handleError(error, "Upload audio note change")
				}
			}
		}
		catch {
			handleError(error)
		}
	}
	// MARK - public interface

	@MainActor
	func toggleAudioRecording() {
		if audioRecording.store.isRecording {
			let recording = audioRecording.stopRecording()
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
		else {
			audioRecording.startRecording()
		}
	}
	@MainActor
	func onAppear() {
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
	@MainActor
	init(
		audioRecording: AudioRecordingControllerPreview? = nil,
		network: NetworkControllerPreview = NetworkControllerPreview(),
		notes: NotesControllerPreview = NotesControllerPreview()
	) {
		let store = RootStore()
		super.init(
			audioRecording: audioRecording
				?? AudioRecordingControllerPreview(store.audioRecording),
			network: network,
			notes: notes,
			store: store
		)
	}

	override func onAppear() {

	}
	override func onInit() {

	}
}
