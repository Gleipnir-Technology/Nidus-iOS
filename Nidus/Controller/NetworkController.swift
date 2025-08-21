import OSLog
import SwiftUI

@Observable
class NetworkController {
	var backgroundNetworkProgress: Double = 0.0
	var backgroundNetworkState: BackgroundNetworkState = .idle

	private var service: NetworkService = NetworkService()

	init() {

	}
	// MARK - public interface
	func fetchNoteUpdates() async throws -> NotesResponse {
		return try await service.fetchNoteUpdates()
	}

	func onInit() {
		Task {
			await service.setCallbacks(
				onError: self.handleError,
				onProgress: self.handleProgress
			)
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
