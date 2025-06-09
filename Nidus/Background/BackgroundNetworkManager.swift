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

class BackgroundDownloadWrapper: NSObject, ObservableObject, URLSessionDownloadDelegate {
	private var backgroundSession: URLSession!
	private var continuations: [URLSessionTask: CheckedContinuation<URL, Error>] = [:]
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

	func handle(_ request: URLRequest) async throws -> URL {
		return try await withCheckedThrowingContinuation {
			(continuation: CheckedContinuation<URL, Error>) in
			let task = backgroundSession.downloadTask(with: request)
			continuations[task] = continuation
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
		guard let continuation = continuations.removeValue(forKey: downloadTask) else {
			return
		}

		do {
			// Create permanent URL
			let originalURL =
				downloadTask.originalRequest?.url ?? URL(string: "downloaded_file")!
			let permanentURL = permanentURL(for: originalURL)

			// Remove existing file if it exists
			if FileManager.default.fileExists(atPath: permanentURL.path) {
				try FileManager.default.removeItem(at: permanentURL)
			}

			// Move the temporary file to permanent location
			try FileManager.default.moveItem(at: location, to: permanentURL)

			// Resume continuation with permanent URL
			continuation.resume(returning: permanentURL)
		}
		catch {
			continuation.resume(throwing: error)
		}
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
	case notConfigured
	case savingData
}

actor BackgroundNetworkManager {
	private var continuations: [URLSessionTask: CheckedContinuation<(), Error>] = [:]
	private var downloadWrapper: BackgroundDownloadWrapper!
	nonisolated let onAPIResponse: ((APIResponse) -> Void)
	nonisolated let onStateChange: ((BackgroundNetworkState) -> Void)

	@Published var isLoggedIn = false

	init(
		onAPIResponse: @escaping ((APIResponse) -> Void),
		onStateChange: @escaping ((BackgroundNetworkState) -> Void)
	) {
		self.downloadWrapper = BackgroundDownloadWrapper()
		self.onAPIResponse = onAPIResponse
		self.onStateChange = onStateChange
	}

	private var currentSettings: Settings {
		let password = UserDefaults.standard.string(forKey: "password") ?? ""
		let url =
			UserDefaults.standard.string(forKey: "sync-url")
			?? "https://sync.nidus.cloud"
		let username = UserDefaults.standard.string(forKey: "username") ?? ""
		return Settings(password: password, URL: url, username: username)
	}

	private func fetchNotes() async throws -> APIResponse {
		updateState(.downloading)
		let url = URL(string: "https://sync.nidus.cloud/api/client/ios")!
		let request = URLRequest(url: url)
		let tempURL = try await downloadWrapper.handle(request)
		let notes: APIResponse = try parseJSON(tempURL)
		return notes
	}

	nonisolated func startBackgroundDownload() async throws {
		await updateState(.idle)
		let settings = await currentSettings
		if settings.username == "" || settings.password == "" {
			Logger.background.info("Refusing to do download, no username and password")
			await updateState(.notConfigured)
			return
		}
		try await login(settings)
		let apiResponse = try await fetchNotes()
		await updateState(.savingData)
		onAPIResponse(apiResponse)
		await updateState(.idle)
	}

	private func login(_ settings: Settings) async throws {
		updateState(.loggingIn)
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
		_ = try await downloadWrapper.handle(request)
	}

	private func parseJSON<T: Decodable>(_ tempURL: URL) throws -> T {
		let data = try Data(contentsOf: tempURL)
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601withOptionalFractionalSeconds
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		let response = try decoder.decode(T.self, from: data)
		return response
	}

	private func updateState(_ newState: BackgroundNetworkState) {
		onStateChange(newState)
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
