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
		do {
			await service.setCallbacks(
				onError: self.handleError,
				onProgress: self.handleProgress
			)
			//try await downloadNotes()
			try await uploadAudioNotes()
		}
		catch {
			Logger.background.error(
				"Failed network controller initialization: \(error)"
			)
			self.backgroundNetworkState = .error
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

	func uploadAudioNote(_ recording: AudioNote) async throws {
		self.backgroundNetworkState = .uploadingChanges
		try await service.uploadAudioNote(recording)
	}
	func uploadNote(_ note: NidusNote) async throws {
		try await service.uploadNote(note)
	}

	func uploadImage(_ id: UUID) async throws {
		try await service.uploadImage(id)
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

	private func uploadAudioNotes() async throws {
		guard let notes = self.notes else {
			Logger.background.error(
				"Notes controller not set for network controller"
			)
			return
		}
		let audioNotes = try notes.notesNeedingUploadAudio()
		for note in audioNotes {
			try await uploadAudioNote(note)
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
