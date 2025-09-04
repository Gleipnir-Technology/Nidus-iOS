import OSLog
import Sentry
import SwiftUI

@Observable
class NetworkController {
	var backgroundNetworkProgress: Double = 0.0
	var backgroundNetworkState: BackgroundNetworkState = .idle

	private var progress: Progressor? = nil
	private var service: NetworkService = NetworkService()
	private var syncTask: Task<(), Never>? = nil

	// MARK - public interface

	/// Test the new settings and save off the credentials if they work, then initiatek
	func onSettingsChanged(_ newSettings: SettingsModel, _ database: DatabaseController) {
		if newSettings.username.isEmpty || newSettings.password.isEmpty {
			setState(.notConfigured, 0.0)
			return
		}
		if self.syncTask != nil {
			self.syncTask!.cancel()
		}
		self.syncTask = Task {
			// Use a loop so that we can try with some backoff
			while true {
				do {
					setState(.loggingIn, 0.0)
					try await self.service.onSettingsChanged(newSettings)

					//try await downloadNotes(database)
					try await uploadAudioNotes(database)
					try await uploadPictureNotes(database)
					//await database.optimize()
					return
				}
				catch AuthError.invalidCredentials {
					Logger.background.info("Credentials are invalid")
					setState(.invalidCredentials, 0.0)
					return
				}
				catch AuthError.noCredentials {
					Logger.background.error(
						"No credentials reported when we have settings. This implies a bug in Nidus"
					)
					return
				}
				catch URLError.cancelled {
					Logger.background.info(
						"Ignoring cancelled task, it means we got new settings"
					)
					return
				}
				catch URLError.notConnectedToInternet {
					Logger.background.info(
						"Not connected to the internet, will retry"
					)
					// retry
				}
				catch URLError.badURL {
					Logger.background.info(
						"URL is bad, credentials are invalid"
					)
					setState(.invalidCredentials, 0.0)
					return
				}
				catch URLError.networkConnectionLost {
					Logger.background.info(
						"Network connection lost, will retry"
					)
					// retry
				}
				catch URLError.timedOut {
					Logger.background.info(
						"Network connection lost, will retry"
					)
					// retry
				}
				catch {
					Logger.background.error(
						"Unhandled error in network controller: \(error)"
					)
					SentrySDK.capture(error: error)
					setState(.error, 0.0)
				}
			}
		}
	}

	func uploadNoteAudio(_ audio: AudioNote) async throws {
		setState(.uploadingChanges, 0.0)
		try await internalUploadNoteAudio(audio) { progress in
			self.setState(.uploadingChanges, progress)
		}
		setState(.idle, 0.0)
	}
	func uploadNotePicture(_ picture: PictureNote) async throws {
		setState(.uploadingChanges, 0.0)
		try await internalUploadNotePicture(picture) { progress in
			self.setState(.uploadingChanges, progress)
		}
		setState(.idle, 0.0)
	}

	// MARK - private functions
	private func downloadNotes(_ database: DatabaseController) async throws {
		setState(.downloading, 0.0)
		let response = try await service.fetchNoteUpdates { progress in
			self.setState(.downloading, progress)
		}
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
	private func handleError(_ error: any Error) {
		Logger.background.error("Network controller error: \(error)")
	}

	private func internalUploadNoteAudio(
		_ audioNote: AudioNote,
		_ onProgress: @escaping (Double) -> Void
	) async throws {
		try await service.uploadNoteAudio(audioNote) { progress in
			onProgress(progress)
		}
	}
	private func internalUploadNotePicture(
		_ pictureNote: PictureNote,
		_ onProgress: @escaping (Double) -> Void
	) async throws {
		try await service.uploadNotePicture(pictureNote) { progress in
			onProgress(progress)
		}
	}

	private func progressStart(_ state: BackgroundNetworkState) {
		if progress != nil {
			Logger.background.error("Previous progress was not correctly reset")
		}
		progress = Progressor()
		setState(state, 0.05)
	}

	private func progressAddSections(_ sections: Int) {
		guard let progress = progress else {
			Logger.background.error("Can't add sections without progressStart")
			return
		}
		progress.totalSections = sections
	}

	private func progressStartSection(_ section: Int) {
		guard let progress = progress else {
			Logger.background.error("Can't add sections without progressStart")
			return
		}
		progress.currentSection = section
	}

	private func progressUpdateSection(_ section: Int, _ p: Double) {
		guard let progress = progress else {
			Logger.background.error("Can't update section without progressStart")
			return
		}
		let progressPerSection = 1.0 / Double(progress.totalSections)
		let sectionProgress = progressPerSection * p
		let totalProgress =
			progressPerSection * Double(progress.currentSection) + sectionProgress
		self.setState(backgroundNetworkState, totalProgress)
	}

	private func progressEnd() {
		progress = nil
		setState(.idle, 0.0)
	}

	private func setState(_ state: BackgroundNetworkState, _ progress: Double) {
		Task { @MainActor in
			if self.backgroundNetworkState != state {
				Logger.background.info(
					"Network state set: \(String(reflecting: state)), progress: \(progress)"
				)
			}
			else if progress >= 1.0 {
				Logger.background.info("Network progress set to \(progress)")
			}
			self.backgroundNetworkProgress = progress
			self.backgroundNetworkState = state
		}
	}

	/// Find all of the notes that haven't been uploaded and upload them
	private func uploadAudioNotes(_ database: DatabaseController) async throws {
		progressStart(.uploadingChanges)
		let audioNotes = try database.service.audioThatNeedsUpload()
		progressAddSections(audioNotes.count)
		Logger.background.info("audio notes to upload: \(audioNotes.count)")
		for (i, note) in audioNotes.enumerated() {
			progressStartSection(i)
			do {
				try await internalUploadNoteAudio(note) { progress in
					self.progressUpdateSection(i, progress)
				}
				_ = try database.service.noteAudioUploaded(
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
		progressEnd()
	}

	private func uploadPictureNotes(_ database: DatabaseController) async throws {
		progressStart(.uploadingChanges)
		let pictureNotes = try database.service.picturesThatNeedUpload()
		progressAddSections(pictureNotes.count)
		Logger.background.info("picture notes to upload: \(pictureNotes.count)")
		for (i, note) in pictureNotes.enumerated() {
			progressStartSection(i)
			do {
				try await internalUploadNotePicture(note) { progress in
					self.progressUpdateSection(i, progress)
				}
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
		progressEnd()
	}
}

class Progressor {
	var currentSection: Int
	var totalSections: Int

	init() {
		self.currentSection = 1
		self.totalSections = 1
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
