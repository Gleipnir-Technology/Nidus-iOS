import Foundation
import OSLog
import UIKit

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
	case invalidCredentials
	case loggingIn
	case uploadingChanges
	case notConfigured
	case savingData
	case updatingSummaries
}

enum NetworkServiceError: Error {
	case settingsNotSet
}

actor NetworkService {
	private var continuations: [URLSessionTask: CheckedContinuation<(), Error>] = [:]
	private var downloadWrapper: BackgroundDownloadWrapper = BackgroundDownloadWrapper()
	private var settings: SettingsModel? = nil

	var isLoggedIn = false

	// MARK - public interfaces
	func fetchNoteUpdates(_ onProgress: @escaping (Double) -> Void) async throws
		-> NotesResponse
	{
		guard let settings = self.settings else {
			throw NetworkServiceError.settingsNotSet
		}
		let url = URL(string: settings.URL + "/api/client/ios")!
		let request = URLRequest(url: url)
		var response: NotesResponse?
		let tempURL = try await downloadWrapper.handle(with: request) { progress in
			onProgress(progress.progress)
		}
		response = try parseJSON(tempURL)
		return response!
	}

	func onSettingsChanged(_ newSettings: SettingsModel) async throws {
		for c in continuations {
			c.key.cancel()
		}
		self.settings = newSettings
		try await login(newSettings)
		/*self.downloadWrapper.setAuthentication(
			password: newSettings.password,
			username: newSettings.username
		)*/
	}

	func uploadNoteAudio(_ recording: AudioNote, _ progressCallback: @escaping (Double) -> Void)
		async throws
	{
		// Upload the data for the note first because the server will validate the UUID
		try await uploadDataAudio(recording) { progress in
			progressCallback(progress * 0.1)
		}
		// Upload the actual audio file
		try await uploadFileAudio(recording.id) { progress in
			progressCallback((progress * 0.9) + 0.1)
		}
	}

	func uploadNotePicture(
		_ recording: PictureNote,
		_ progressCallback: @escaping (Double) -> Void
	) async throws {
		// Upload the data for the note first because the server will validate the UUID
		try await uploadDataPicture(recording) { progress in
			progressCallback(progress * 0.1)
		}
		// Upload the actual picture file
		try await uploadFilePicture(recording.id) { progress in
			progressCallback((progress * 0.9) + 0.1)
		}
	}

	private func uploadDataAudio(
		_ recording: AudioNote,
		_ progressCallback: @escaping (Double) -> Void
	) async throws {
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
		encoder.outputFormatting = .prettyPrinted
		let data = try encoder.encode(recording)
		request.httpBody = data
		Logger.background.info(
			"Begin upload of audio data \(recording.id): \n\(String(data: data, encoding: .utf8)!)"
		)
		_ = try await downloadWrapper.handle(with: request) { progress in
			progressCallback(progress.progress)
		}
		Logger.background.info("Audio data \(recording.id) uploaded successfully")
	}

	private func uploadDataPicture(
		_ picture: PictureNote,
		_ progressCallback: @escaping (Double) -> Void
	) async throws {
		guard let settings = self.settings else {
			throw NetworkServiceError.settingsNotSet
		}
		let uploadURL: URL = URL(
			string: settings.URL + "/api/image/" + picture.id.uuidString
		)!

		var request = URLRequest(url: uploadURL)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let data = try encoder.encode(picture)
		request.httpBody = data
		Logger.background.info("Begin upload of picture data \(picture.id)")
		_ = try await downloadWrapper.handle(with: request) { progress in
			progressCallback(progress.progress)
		}
		Logger.background.info("Picture data \(picture.id) uploaded successfully")
	}

	private func uploadFileAudio(_ uuid: UUID, _ progressCallback: @escaping (Double) -> Void)
		async throws
	{
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
		request.httpBody = try Data(contentsOf: audioURL)

		// Create upload task with file URL
		Logger.background.info("Begin upload of audio file \(uuid)")
		_ = try await downloadWrapper.handle(with: request) { progress in
			progressCallback(progress.progress)
		}
		Logger.background.info("Audio file \(uuid) uploaded successfully")
	}

	func uploadFilePicture(_ uuid: UUID, _ progressCallback: @escaping (Double) -> Void)
		async throws
	{
		guard let settings = self.settings else {
			throw NetworkServiceError.settingsNotSet
		}
		let uploadURL: URL = URL(
			string: settings.URL + "/api/image/" + uuid.uuidString + "/content"
		)!
		let imageURL = PictureNote.url(uuid)

		// Check if file exists
		guard FileManager.default.fileExists(atPath: imageURL.path) else {
			throw ImageUploadError.fileNotFound
		}

		// Create the request
		var request = URLRequest(url: uploadURL)
		request.httpBody = try Data(contentsOf: imageURL)
		request.httpMethod = "POST"
		request.setValue("image/png", forHTTPHeaderField: "Content-Type")

		// Create upload task with file URL
		Logger.background.info("Begin upload of picture file \(uuid)")
		_ = try await downloadWrapper.handle(with: request) { progress in
			progressCallback(progress.progress)
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
		_ = try await downloadWrapper.handle(with: request)
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
