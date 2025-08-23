import OSLog
import Sentry
import SwiftUI

@Observable
class NetworkController {
	var backgroundNetworkProgress: Double = 0.0
	var backgroundNetworkState: BackgroundNetworkState = .idle

	private var service: NetworkService = NetworkService()

	// MARK - public interface
	func downloadNotes(_ database: DatabaseController) async {
		setState(.downloading, 0.0)
		do {
			let response = try await service.fetchNoteUpdates()
			setState(.savingData, 0.0)
			let totalRecords =
				response.requests.count + response.sources.count
				+ response.traps.count
			var i = 0
			for r in response.requests {
				try database.service.upsertServiceRequest(r)
				i += 1
				if i % 100 == 0 {
					setState(.savingData, Double(i) / Double(totalRecords))
				}
			}
			for s in response.sources {
				try database.service.upsertSource(s)
				i += 1
				if i % 100 == 0 {
					setState(.savingData, Double(i) / Double(totalRecords))
				}
			}
			setState(.idle, 0.0)
			Logger.background.info("Done saving API response")
		}
		catch {
			SentrySDK.capture(error: error)
			Logger.background.error("Failed to fetch updates: \(error)")
			setState(.error, 0.0)
			return
		}

	}
	func fetchNoteUpdates() async throws -> NotesResponse {
		return try await service.fetchNoteUpdates()
	}

	func onInit() {
		setState(.idle, 0.0)
		Task {
			await service.setCallbacks(
				onError: self.handleError,
				onProgress: self.handleProgress
			)
			Logger.background.info("Set callbacks for network service")
		}
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
		setState(.uploadingChanges, 0.0)
		try await service.uploadNoteAudio(recording) { progress in
			self.setState(.uploadingChanges, progress)
		}
	}
	func uploadNotePicture(_ picture: PictureNote) async throws {
		setState(.uploadingChanges, 0.0)
		try await service.uploadNotePicture(picture) { progress in
			self.setState(.uploadingChanges, progress)
		}
	}

	/// Find all of the notes that haven't been uploaded and upload them
	func uploadAudioNotes(_ database: DatabaseController) async {
		do {
			let audioNotes = try database.service.audioThatNeedsUpload()
			Logger.background.info("audio notes to upload: \(audioNotes.count)")
			for note in audioNotes {
				do {
					try await uploadNoteAudio(note)
					try database.service.updateNoteAudio(
						note,
						uploaded: Date.now
					)
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

	func uploadPictureNotes(_ database: DatabaseController) async {
		do {
			let pictureNotes = try database.service.picturesThatNeedUpload()
			Logger.background.info("picture notes to upload: \(pictureNotes.count)")
			for note in pictureNotes {
				do {
					try await uploadNotePicture(note)
				}
				catch {
					Logger.background.error(
						"Failed to upload picture note \(note.id): \(error)"
					)
				}
				do {
					try database.service.updateNotePicture(
						note,
						uploaded: Date.now
					)
				}
				catch {
					Logger.background.error(
						"Failed to save picture note uploaded date \(note.id): \(error)"
					)
				}
			}
		}
		catch {
			Logger.background.error("Failed to get notes that need uploading: \(error)")
		}
	}
	// MARK - private functions
	private func handleError(_ error: any Error) {
		Logger.background.error("Network controller error: \(error)")
	}

	private func handleProgress(_ progress: Double) {
		self.backgroundNetworkProgress = progress
		Logger.background.info("Network progress: \(progress)")
	}

	private func setState(_ state: BackgroundNetworkState, _ progress: Double) {
		self.backgroundNetworkProgress = progress
		self.backgroundNetworkState = state
		Logger.background.info(
			"Network state set: \(state.hashValue), progress: \(progress)"
		)
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
