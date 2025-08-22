import OSLog
import SwiftUI

@Observable
class NetworkController {
	var backgroundNetworkProgress: Double = 0.0
	var backgroundNetworkState: BackgroundNetworkState = .idle
	var notes: NotesController? = nil

	private var service: NetworkService = NetworkService()

	// MARK - public interface
	func fetchNoteUpdates() async throws -> NotesResponse {
		return try await service.fetchNoteUpdates()
	}

	func Load() async {
		self.backgroundNetworkProgress = 0.0
		self.backgroundNetworkState = .idle
		await service.setCallbacks(
			onError: self.handleError,
			onProgress: self.handleProgress
		)
		startTasks()
	}

	func onSettingsChanged(_ newSettings: SettingsModel) {
		Task {
			await self.service.handleSettingsChanged(newSettings)
			if newSettings.URL.isEmpty || newSettings.password.isEmpty
				|| newSettings.username.isEmpty
			{
				return
			}

		}
	}

	func uploadNoteAudio(_ recording: AudioNote) async throws {
		self.backgroundNetworkState = .uploadingChanges
		try await service.uploadNoteAudio(recording)
	}
	func uploadNotePicture(_ picture: PictureNote) async throws {
		self.backgroundNetworkState = .uploadingChanges
		try await service.uploadNotePicture(picture)
	}

	func uploadNote(_ note: NidusNote) async throws {
		try await service.uploadNote(note)
	}

	// MARK - private functions
	private func downloadNotes() async throws {
		guard let notesController = self.notes else {
			Logger.background.error(
				"Notes controller not set for network controller"
			)
			return
		}
		self.backgroundNetworkState = .downloading
		let response = try await service.fetchNoteUpdates()
		self.backgroundNetworkState = .savingData
		Logger.background.info("Begin saving API response")
		let totalRecords =
			response.requests.count + response.sources.count
			+ response.traps.count
		var i = 0
		for r in response.requests {
			try notesController.upsertServiceRequest(r)
			i += 1
			if i % 100 == 0 {
				self.backgroundNetworkProgress =
					Double(i) / Double(totalRecords)
			}
		}
		for s in response.sources {
			try notesController.upsertSource(s)
			i += 1
			if i % 100 == 0 {
				self.backgroundNetworkProgress =
					Double(i) / Double(totalRecords)
			}
		}
		self.backgroundNetworkState = .idle
		self.backgroundNetworkProgress = 0.0
		Logger.background.info("Done saving API response")

	}
	private func handleError(_ error: any Error) {
		Logger.background.error("Network controller error: \(error)")
	}

	private func handleProgress(_ progress: Double) {
		self.backgroundNetworkProgress = progress
		//Logger.background.info("Network progress: \(progress)")
	}

	/// Kick off the different background tasks we should be doing
	private func startTasks() {
		Task {
			//await downloadNotes()
			await uploadAudioNotes()
			await uploadPictureNotes()
		}
	}
	/// Find all of the notes that haven't been uploaded and upload them
	private func uploadAudioNotes() async {
		guard let notes = self.notes else {
			Logger.background.error(
				"Notes controller not set for network controller"
			)
			return
		}
		do {
			let audioNotes = try notes.notesNeedingUploadAudio()
			Logger.background.info("audio notes to upload: \(audioNotes.count)")
			for note in audioNotes {
				do {
					try await uploadNoteAudio(note)
					try notes.updateNoteAudio(note, uploaded: Date.now)
				}
				catch {
					Logger.background.error(
						"Failed to upload audio note \(note.id): \(error)"
					)
				}
			}
		}
		catch {
			Logger.background.error("Failed to get notes that need uploading: \(error)")
		}
	}

	private func uploadPictureNotes() async {
		guard let notes = self.notes else {
			Logger.background.error(
				"Notes controller not set for network controller"
			)
			return
		}
		do {
			let pictureNotes = try notes.notesNeedingUploadPicture()
			Logger.background.info("picture notes to upload: \(pictureNotes.count)")
			for note in pictureNotes {
				do {
					try await uploadNotePicture(note)
					try notes.updateNotePicture(note, uploaded: Date.now)
				}
				catch {
					Logger.background.error(
						"Failed to upload picture note \(note.id): \(error)"
					)
				}
			}
		}
		catch {
			Logger.background.error("Failed to get notes that need uploading: \(error)")
		}
	}
}

class NetworkControllerPreview: NetworkController {
	init(
		backgroundNetworkProgress: Double = 0.0,
		backgroundNetworkState: BackgroundNetworkState = .notConfigured
	) {
		super.init()
		self.backgroundNetworkProgress = backgroundNetworkProgress
		self.backgroundNetworkState = backgroundNetworkState
	}
}
