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

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
	@Published var errorMessage: String?
	private var manager: BackgroundNetworkManager!
	var model: NidusModel?

	func setManager(_ manager: BackgroundNetworkManager, _ model: NidusModel) {
		self.model = model
		self.manager = manager
	}

	private func requestById(_ id: UUID) -> ServiceRequest? {
		return nil
	}

	private func sourceById(_ id: UUID) -> MosquitoSource? {
		return nil
	}

	private func trapById(_ id: UUID) -> TrapData? {
		return nil
	}

	private func saveResponse(_ response: APIResponse) {
		Logger.background.info("Saving API response")
		Logger.background.info("Sources \(response.sources.count)")
		Logger.background.info("Requests \(response.requests.count)")
		Logger.background.info("Traps \(response.traps.count)")
		var i = 0
		for r in response.requests {
			model?.upsertServiceRequest(r)
			i += 1
			if i % 1000 == 0 {
				Logger.background.info("Request \(i)")
			}
		}
		i = 0
		for s in response.sources {
			model?.upsertSource(s)
			i += 1
			if i % 1000 == 0 {
				Logger.background.info("Source \(i)")
			}
		}
		model?.triggerUpdateComplete()
		Logger.background.info("Done saving response")
	}

	func urlSession(
		_ session: URLSession,
		downloadTask: URLSessionDownloadTask,
		didFinishDownloadingTo location: URL
	) {
		Logger.background.info("urlSession did finish downloading")
		let msg: String = downloadTask.originalRequest?.url?.absoluteString ?? "no url"
		Logger.background.info("\(String(describing: msg))")
		if downloadTask.originalRequest?.url?.absoluteString
			== "https://sync.nidus.cloud/login"
		{
			// Try the next request, assuming that we have proper cookies
			Task {
				await manager.fetchNotes()
			}
		}
		else if downloadTask.originalRequest?.url?.absoluteString
			== "https://sync.nidus.cloud/api/client/ios"
		{
			do {
				let data = try Data(contentsOf: location)
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601withOptionalFractionalSeconds
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				let apiResponse = try decoder.decode(
					APIResponse.self,
					from: data
				)

				saveResponse(apiResponse)

			}
			catch {
				Logger.background.error(
					"Failed to process download: \(error)"
				)
			}

		}
		else {
			Logger.background.info("not sure what to do next")
		}
	}

	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didCompleteWithError error: Error?
	) {
		if let error = error {
			self.errorMessage = "Download failed: \(error.localizedDescription)"
		}
	}

	func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
		Logger.background.info("urlSessionDidFinishEvents")
		DispatchQueue.main.async {
			guard let appDelegate = UIApplication.shared.delegate as? NidusAppDelegate,
				let backgroundCompletionHandler = appDelegate
					.backgroundCompletionHandler
			else {
				return
			}
			backgroundCompletionHandler()
		}
	}
}
actor BackgroundNetworkManager: ObservableObject {
	private var backgroundSession: URLSession!
	private let cookieStorage: HTTPCookieStorage
	private var downloadDelegate: DownloadDelegate
	private var model: NidusModel

	@Published var isLoggedIn = false

	init(_ model: NidusModel) {
		cookieStorage = HTTPCookieStorage.shared
		self.model = model
		downloadDelegate = DownloadDelegate()

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
			delegate: downloadDelegate,
			delegateQueue: nil
		)

		downloadDelegate.setManager(self, model)
	}

	private var currentSettings: Settings {
		let password = UserDefaults.standard.string(forKey: "password") ?? ""
		let url =
			UserDefaults.standard.string(forKey: "sync-url")
			?? "https://sync.nidus.cloud"
		let username = UserDefaults.standard.string(forKey: "username") ?? ""
		return Settings(password: password, URL: url, username: username)
	}

	func fetchNotes() async {
		Logger.background.info("Fetching notes")
		guard let url = URL(string: "https://sync.nidus.cloud/api/client/ios") else {
			return
		}

		let downloadTask = backgroundSession.downloadTask(with: url)
		downloadTask.resume()

	}

	nonisolated func startBackgroundDownload() async throws {
		let settings = await currentSettings
		if settings.username != "" && settings.password != "" {
			await login(settings)
		}
		else {
			Logger.background.info("Refusing to do download, no username and password")
		}
	}

	func login(_ settings: Settings) async {
		guard let loginURL = URL(string: settings.URL + "/login") else {
			Logger.background.error("Invalid login URL")
			return
		}

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
		let downloadTask = backgroundSession.downloadTask(with: request)
		downloadTask.resume()
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
