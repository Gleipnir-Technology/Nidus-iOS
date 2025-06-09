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
	func urlSession(
		_ session: URLSession,
		downloadTask: URLSessionDownloadTask,
		didFinishDownloadingTo location: URL
	) {
		if let continuation = continuations.removeValue(forKey: downloadTask) {
			continuation.resume(returning: location)
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

actor BackgroundNetworkManager: ObservableObject {
	private var continuations: [URLSessionTask: CheckedContinuation<(), Error>] = [:]
	private var downloadWrapper: BackgroundDownloadWrapper!
	private var model: NidusModel

	@Published var isLoggedIn = false

	init(_ model: NidusModel) {
		self.model = model
		self.downloadWrapper = BackgroundDownloadWrapper()
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
		let url = URL(string: "https://sync.nidus.cloud/api/client/ios")!
		let request = URLRequest(url: url)
		let tempURL = try await downloadWrapper.handle(request)
		let notes: APIResponse = try parseJSON(tempURL)
		return notes
	}

	nonisolated func startBackgroundDownload() async throws {
		let settings = await currentSettings
		if settings.username == "" || settings.password == "" {
			Logger.background.info("Refusing to do download, no username and password")
			return
		}
		try await login(settings)
		let apiResponse = try await fetchNotes()
		await saveResponse(apiResponse)
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

	private func saveResponse(_ response: APIResponse) {
		Logger.background.info("Saving API response")
		Logger.background.info("Sources \(response.sources.count)")
		Logger.background.info("Requests \(response.requests.count)")
		Logger.background.info("Traps \(response.traps.count)")
		var i = 0
		for r in response.requests {
			model.upsertServiceRequest(r)
			i += 1
			if i % 1000 == 0 {
				Logger.background.info("Request \(i)")
			}
		}
		i = 0
		for s in response.sources {
			model.upsertSource(s)
			i += 1
			if i % 1000 == 0 {
				Logger.background.info("Source \(i)")
			}
		}
		model.triggerUpdateComplete()
		Logger.background.info("Done saving response")
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
