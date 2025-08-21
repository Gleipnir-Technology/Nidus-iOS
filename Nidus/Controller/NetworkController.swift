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

	func onInit() {
		self.backgroundNetworkProgress = 0.0
		Task {
			do {
				await service.setCallbacks(
					onError: self.handleError,
					onProgress: self.handleProgress
				)
				guard let notesController = self.notes else {
					Logger.background.error(
						"Notes controller not set for network controller"
					)
					return
				}
				let response = try await service.fetchNoteUpdates()
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
				Logger.background.info("Done saving API response")
			}
			catch {
				Logger.background.error(
					"Failed network controller initialization: \(error)"
				)
			}
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

	func uploadAudio(_ id: UUID) async throws {
		try await service.uploadAudio(id)
	}

	func uploadNote(_ note: NidusNote) async throws {
		try await service.uploadNote(note)
	}

	func uploadImage(_ id: UUID) async throws {
		try await service.uploadImage(id)
	}

	// MARK - private functions
	private func handleError(_ error: any Error) {

	}

	private func handleProgress(_ progress: Double) {
		self.backgroundNetworkProgress = progress
	}
}
