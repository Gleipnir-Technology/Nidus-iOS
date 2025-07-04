//
//  BackgroundNetworkManager.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/27/25.
//
import Foundation
import OSLog
import SQLite
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

class BackgroundDownloadWrapper: NSObject, ObservableObject, URLSessionDownloadDelegate {
	private var backgroundSession: URLSession!
	private var continuations: [URLSessionTask: CheckedContinuation<URL, Error>] = [:]
	private var progressHandlers: [URLSessionTask: (DownloadProgress) -> Void] = [:]

	private let cookieStorage: HTTPCookieStorage

	override init() {
		self.cookieStorage = HTTPCookieStorage.shared
		super.init()
		let config = URLSessionConfiguration.background(
			withIdentifier: "technology.gleipnir.nidus-notes.download-session"
		)
		config.isDiscretionary = false
		config.sessionSendsLaunchEvents = true
		config.httpCookieStorage = cookieStorage
		config.httpShouldSetCookies = true
		config.httpCookieAcceptPolicy = .always

		backgroundSession = URLSession(
			configuration: config,
			delegate: self,
			delegateQueue: nil
		)
	}

	func handle(
		with request: URLRequest,
		progressHandler: @escaping (DownloadProgress) -> Void = { _ in }
	) async throws -> URL {
		return try await withCheckedThrowingContinuation {
			(continuation: CheckedContinuation<URL, Error>) in
			let task = backgroundSession.downloadTask(with: request)
			continuations[task] = continuation
			progressHandlers[task] = progressHandler
			task.resume()
		}
	}

	private func permanentURL(for originalURL: URL) -> URL {
		let documentsPath = FileManager.default.urls(
			for: .documentDirectory,
			in: .userDomainMask
		)[0]
		let filename = originalURL.lastPathComponent
		return documentsPath.appendingPathComponent(filename)
	}

	func urlSession(
		_ session: URLSession,
		downloadTask: URLSessionDownloadTask,
		didFinishDownloadingTo location: URL
	) {
		progressHandlers.removeValue(forKey: downloadTask)

		guard let continuation = continuations.removeValue(forKey: downloadTask) else {
			return
		}

		do {
			let originalURL =
				downloadTask.originalRequest?.url ?? URL(
					string: "downloaded_file"
				)!
			if let httpResponse = downloadTask.response as? HTTPURLResponse {
				let statusCode = httpResponse.statusCode
				switch statusCode {
				case 200..<300:
					// Create permanent URL
					let permanentURL = permanentURL(for: originalURL)

					// Remove existing file if it exists
					if FileManager.default.fileExists(atPath: permanentURL.path)
					{
						try FileManager.default.removeItem(at: permanentURL)
					}

					// Move the temporary file to permanent location
					try FileManager.default.moveItem(
						at: location,
						to: permanentURL
					)
					// Resume continuation with permanent URL
					continuation.resume(returning: permanentURL)
					break
				default:
					let data = try Data(contentsOf: location)
					let content = String(data: data, encoding: .utf8)
					Logger.background.error(
						"Generating a URLError with status code \(statusCode) for URL \(originalURL.path): \(content ?? "")"
					)
					continuation.resume(
						throwing: URLError(
							URLError.Code(rawValue: statusCode)
						)
					)
				}
			}

		}
		catch {
			continuation.resume(throwing: error)
		}
	}

	func urlSession(
		_ session: URLSession,
		downloadTask: URLSessionDownloadTask,
		didWriteData bytesWritten: Int64,
		totalBytesWritten: Int64,
		totalBytesExpectedToWrite: Int64
	) {

		let progress = DownloadProgress(
			bytesWritten: totalBytesWritten,
			totalBytesExpected: totalBytesExpectedToWrite,
			progress: totalBytesExpectedToWrite > 0
				? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) : 0
		)

		progressHandlers[downloadTask]?(progress)
	}

	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didCompleteWithError error: Error?
	) {
		if let error = error, let continuation = continuations.removeValue(forKey: task) {
			continuation.resume(throwing: error)
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

actor BackgroundNetworkManager {
	private var continuations: [URLSessionTask: CheckedContinuation<(), Error>] = [:]
	private var downloadWrapper: BackgroundDownloadWrapper!
	nonisolated let onError: ((any Error) -> Void)
	nonisolated let onProgress: ((Double) -> Void)

	@Published var isLoggedIn = false

	init(
		onError: @escaping ((any Error) -> Void),
		onProgress: @escaping ((Double) -> Void)
	) {
		self.downloadWrapper = BackgroundDownloadWrapper()
		self.onError = onError
		self.onProgress = onProgress
	}

	nonisolated private func doLogin(_ settings: Settings) async throws {
		if settings.username == "" || settings.password == "" {
			Logger.background.info(
				"Refusing to do download, no username and password"
			)
			return
		}
		try await login(settings)
	}

	func fetchNoteUpdates(_ settings: Settings) async throws -> NotesResponse {
		let url = URL(string: settings.URL + "/api/client/ios")!
		let request = URLRequest(url: url)
		var response: NotesResponse?
		try await maybeLogin(settings) {
			let tempURL = try await downloadWrapper.handle(with: request) { progress in
				self.onProgress(progress.progress)
			}
			response = try parseJSON(tempURL)
		}
		return response!
	}

	nonisolated func uploadAudio(_ settings: Settings, _ uuid: UUID) async throws {
		let uploadURL: URL = URL(string: settings.URL + "/api/audio/" + uuid.uuidString)!
		let audioURL = AudioRecording.url(uuid)

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
	}

	nonisolated func uploadImage(_ settings: Settings, _ uuid: UUID) async throws {
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

	nonisolated func uploadNote(_ settings: Settings, _ note: NidusNote) async throws {
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

	private func login(_ settings: Settings) async throws {
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

	private func maybeLogin(_ settings: Settings, _ block: () async throws -> Void) async throws
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
					try await doLogin(settings)
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
