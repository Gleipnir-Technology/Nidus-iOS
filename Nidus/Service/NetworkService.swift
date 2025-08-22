import Foundation
import OSLog
import UIKit

struct DownloadProgress {
	let bytesWritten: Int64
	let totalBytesExpected: Int64
	let progress: Double
}

enum AudioUploadError: Error {
	case fileNotFound
	case invalidURL

	var localizedDescription: String {
		switch self {
		case .fileNotFound:
			return "Audio file not found"
		case .invalidURL:
			return "Invalid upload URL"
		}
	}
}

enum ImageUploadError: Error {
	case fileNotFound
	case invalidURL

	var localizedDescription: String {
		switch self {
		case .fileNotFound:
			return "Image file not found"
		case .invalidURL:
			return "Invalid upload URL"
		}
	}
}

enum BackgroundNetworkState {
	case downloading
	case error
	case idle
	case loggingIn
	case uploadingChanges
	case notConfigured
	case savingData
}

enum NetworkServiceError: Error {
	case settingsNotSet
}

actor NetworkService {
	private var continuations: [URLSessionTask: CheckedContinuation<(), Error>] = [:]
	private var downloadWrapper: BackgroundDownloadWrapper = BackgroundDownloadWrapper()
	private var settings: SettingsModel? = nil
	var onError: ((any Error) -> Void)? = nil
	var onProgress: ((Double) -> Void)? = nil

	var isLoggedIn = false

	// MARK - public interfaces
	func setCallbacks(
		onError: @escaping (Error) -> Void,
		onProgress: @escaping (Double) -> Void
	) {
		self.onError = onError
		self.onProgress = onProgress
	}

	func connect(_ settings: SettingsModel) async throws {
		if settings.username == "" || settings.password == "" {
			Logger.background.info(
				"Refusing to do download, no username and password"
			)
			return
		}
		try await login(settings)
	}

	func fetchNoteUpdates() async throws -> NotesResponse {
		guard let settings = self.settings else {
			throw NetworkServiceError.settingsNotSet
		}
		let url = URL(string: settings.URL + "/api/client/ios")!
		let request = URLRequest(url: url)
		var response: NotesResponse?
		try await maybeLogin(settings) {
			let tempURL = try await downloadWrapper.handle(with: request) { progress in
				guard let onProgress = self.onProgress else {
					return
				}
				onProgress(progress.progress)
			}
			response = try parseJSON(tempURL)
		}
		return response!
	}

	func handleSettingsChanged(_ newSettings: SettingsModel) {
		self.settings = newSettings
	}

	func uploadAudioNote(_ recording: AudioNote) async throws {
		// Upload the data for the recording first because the server will validate the UUID
		try await uploadAudioData(recording)
		// Upload the actual audio file
		try await uploadAudioFile(recording.id)
	}

	private func uploadAudioData(_ recording: AudioNote) async throws {
		guard let settings = self.settings else {
			throw NetworkServiceError.settingsNotSet
		}
		let uploadURL: URL = URL(
			string: settings.URL + "/api/audio/" + recording.id.uuidString
		)!

		var request = URLRequest(url: uploadURL)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let data = try encoder.encode(recording)
		request.httpBody = data
		try await maybeLogin(settings) {
			_ = try await downloadWrapper.handle(with: request)
		}
		Logger.background.info("Audio data \(recording.id) uploaded successfully")
	}

	private func uploadAudioFile(_ uuid: UUID) async throws {
		guard let settings = self.settings else {
			throw NetworkServiceError.settingsNotSet
		}
		let uploadURL: URL = URL(
			string: settings.URL + "/api/audio/" + uuid.uuidString + "/content"
		)!
		let audioURL = AudioNote.url(uuid)

		// Check if file exists
		guard FileManager.default.fileExists(atPath: audioURL.path) else {
			throw AudioUploadError.fileNotFound
		}

		// Create the request
		var request = URLRequest(url: uploadURL)
		request.httpMethod = "POST"
		request.setValue("audio/m4a", forHTTPHeaderField: "Content-Type")

		// Create upload task with file URL
		try await maybeLogin(settings) {
			_ = try await downloadWrapper.handle(with: request)
		}
		Logger.background.info("Audio file \(uuid) uploaded successfully")
	}

	func uploadImage(_ uuid: UUID) async throws {
		guard let settings = self.settings else {
			throw NetworkServiceError.settingsNotSet
		}
		let uploadURL: URL = URL(string: settings.URL + "/api/image/" + uuid.uuidString)!
		let imageURL = NoteImage.url(uuid)

		// Check if file exists
		guard FileManager.default.fileExists(atPath: imageURL.path) else {
			throw ImageUploadError.fileNotFound
		}

		// Create the request
		var request = URLRequest(url: uploadURL)
		request.httpMethod = "POST"
		request.setValue("image/png", forHTTPHeaderField: "Content-Type")

		// Create upload task with file URL
		try await maybeLogin(settings) {
			_ = try await downloadWrapper.handle(with: request)
		}
	}

	func uploadNote(_ note: NidusNote) async throws {
		guard let settings = self.settings else {
			throw NetworkServiceError.settingsNotSet
		}
		let id: String = String(note.id.uuidString)
		let updateURL: URL = URL(string: settings.URL + "/api/client/ios/note/" + id)!

		// Create form-encoded POST request
		var request = URLRequest(url: updateURL)
		request.httpMethod = "PUT"
		request.setValue(
			"application/json",
			forHTTPHeaderField: "Content-Type"
		)

		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let data = try encoder.encode(note.toPayload())
		// Create json data
		request.httpBody = data
		try await maybeLogin(settings) {
			_ = try await downloadWrapper.handle(with: request)
		}
	}

	private func login(_ settings: SettingsModel) async throws {
		let loginURL: URL = URL(string: settings.URL + "/login")!

		// Create form-encoded POST request
		var request = URLRequest(url: loginURL)
		request.httpMethod = "POST"
		request.setValue(
			"application/x-www-form-urlencoded",
			forHTTPHeaderField: "Content-Type"
		)

		// Create form data
		let formData =
			"username=\(settings.username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&password=\(settings.password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
		request.httpBody = formData.data(using: .utf8)
		_ = try await downloadWrapper.handle(with: request)
	}

	private func maybeLogin(_ settings: SettingsModel, _ block: () async throws -> Void)
		async throws
	{
		do {
			try await block()
		}
		catch {
			Logger.background.error("Request error: \(error)")
			guard let urlError = error as? URLError else {
				throw error
			}
			Logger.background.error(
				"URL error: \(urlError) with code \(urlError.code.rawValue)"
			)
			if urlError.code.rawValue == 401 {
				do {
					try await connect(settings)
				}
				catch {
					Logger.background.error("Failed to login: \(error)")
				}
				try await block()
			}
			else {
				throw error
			}
		}
	}

	private func parseJSON<T: Decodable>(_ tempURL: URL) throws -> T {
		let data = try Data(contentsOf: tempURL)
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601withOptionalFractionalSeconds
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		do {
			let response = try decoder.decode(T.self, from: data)
			return response
		}
		catch {
			Logger.background.error("Failed to parse response as JSON: \(error)")
			Logger.background.info("Trying text")
			let text = String(data: data, encoding: .utf8)
			Logger.background.info("Text is \(text ?? "nil")")
			throw (error)
		}
	}
}

extension ParseStrategy where Self == Date.ISO8601FormatStyle {
	static var iso8601withFractionalSeconds: Self { .init(includingFractionalSeconds: true) }
}

extension JSONDecoder.DateDecodingStrategy {
	static let iso8601withOptionalFractionalSeconds = custom {
		let string = try $0.singleValueContainer().decode(String.self)
		do {
			return try .init(string, strategy: .iso8601withFractionalSeconds)
		}
		catch {
			return try .init(string, strategy: .iso8601)
		}
	}
}
