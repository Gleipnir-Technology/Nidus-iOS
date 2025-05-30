//
//  BackgroundNetworkManager.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/27/25.
//
import Foundation
import OSLog
import SwiftData
import UIKit

struct LocationResponse: Codable {
	let latitude: Double
	let longitude: Double

	func asNoteLocation() -> NoteLocation {
		NoteLocation(latitude: latitude, longitude: longitude)
	}
}

final class APIResponse: Codable {
	enum CodingKeys: CodingKey {
		case requests
		case sources
		case traps
	}

	let requests: [ServiceRequest]
	let sources: [MosquitoSource]
	let traps: [TrapData]

	init(requests: [ServiceRequest], sources: [MosquitoSource], traps: [TrapData]) {
		self.requests = requests
		self.sources = sources
		self.traps = traps
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.requests = try container.decode([ServiceRequest].self, forKey: .requests)
		self.sources = try container.decode([MosquitoSource].self, forKey: .sources)
		self.traps = try container.decode([TrapData].self, forKey: .traps)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(requests, forKey: .requests)
		try container.encode(sources, forKey: .sources)
		try container.encode(traps, forKey: .traps)
	}
}

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
	@Published var errorMessage: String?
	private var modelContext: ModelContext
	private var manager: BackgroundNetworkManager!

	init(with container: ModelContainer) {
		modelContext = ModelContext(container)
	}

	func setManager(_ manager: BackgroundNetworkManager) {
		self.manager = manager
	}

	private func requestById(_ id: UUID) -> ServiceRequest? {
		let fetchDescriptor = FetchDescriptor<ServiceRequest>(
			predicate: #Predicate { $0.id == id }
		)
		do {
			return try modelContext.fetch(fetchDescriptor).first
		}
		catch {
			return nil
		}
	}

	private func sourceById(_ id: UUID) -> MosquitoSource? {
		let fetchDescriptor = FetchDescriptor<MosquitoSource>(
			predicate: #Predicate { $0.id == id }
		)
		do {
			return try modelContext.fetch(fetchDescriptor).first
		}
		catch {
			return nil
		}
	}

	private func trapById(_ id: UUID) -> TrapData? {
		let fetchDescriptor = FetchDescriptor<TrapData>(
			predicate: #Predicate { $0.id == id }
		)
		do {
			return try modelContext.fetch(fetchDescriptor).first
		}
		catch {
			return nil
		}
	}

	private func saveResponse(_ response: APIResponse) {
		MainActor.preconditionIsolated()
		Logger.background.info("Saving API response")
		Logger.background.info("Sources \(response.sources.count)")
		Logger.background.info("Requests \(response.requests.count)")
		Logger.background.info("Traps \(response.traps.count)")
		for s in response.sources {
			if let source = sourceById(s.id) {
				source.access = s.access
				source.comments = s.comments
				source.description_ = s.description_
				source.location = s.location
				source.habitat = s.habitat
				source.inspections = s.inspections
				source.name = s.name
				source.treatments = s.treatments
				source.useType = s.useType
				source.waterOrigin = s.waterOrigin
			}
			else {
				modelContext.insert(s)
			}
		}
		for r in response.requests {
			if let request = requestById(r.id) {
				request.address = r.address
				request.city = r.city
				request.location = r.location
				request.priority = r.priority
				request.source = r.source
				request.status = r.status
				request.target = r.target
				request.zip = r.zip
			}
			else {
				modelContext.insert(r)
			}
		}
		for t in response.traps {
			if let trap = trapById(t.id) {
				trap.description_ = t.description_
				trap.location = t.location
				trap.name = t.name
			}
			else {
				modelContext.insert(t)
			}
		}
		/*
				if let note = noteById(uuid) {
					Logger.background.info(
						"Note \(noteResponse.id) already exists, updating"
					)
					note.categoryName = noteResponse.categoryName
					note.content = noteResponse.content
					note.location = noteResponse.location.asNoteLocation()
					if let timestamp = ISO8601DateFormatter().date(
						from: noteResponse.timestamp
					) {
						note.timestamp = timestamp
					}
					else {
						Logger.background.warning(
							"Cannot parse timestamp \(note.timestamp)"
						)
					}
				}
				else {
					Logger.background.info(
						"Note \(noteResponse.id) does not exist, creating"
					)
					let newNote = Note(
						category: NoteCategory.byNameOrDefault(
							noteResponse.categoryName
						),
						content: noteResponse.content,
						location: noteResponse.location.asNoteLocation()
					)
					newNote.id = uuid
					modelContext.insert(newNote)
				}
         */
		do {
			try modelContext.save()
		}
		catch {
			Logger.background.error(
				"Database save failed: \(error.localizedDescription)"
			)
		}
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
				let apiResponse = try decoder.decode(
					APIResponse.self,
					from: data
				)

				Task { @MainActor in
					saveResponse(apiResponse)
				}

			}
			catch {
				Logger.background.error(
					"Failed to process download: \(error.localizedDescription)"
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
	private var modelContext: ModelContext

	@Published var isLoggedIn = false

	// From @ModelActor
	nonisolated let modelExecutor: any SwiftData.ModelExecutor
	nonisolated let modelContainer: SwiftData.ModelContainer

	init(with container: SwiftData.ModelContainer) {
		cookieStorage = HTTPCookieStorage.shared
		downloadDelegate = DownloadDelegate(with: container)
		modelContext = ModelContext(container)

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

		// From @ModelActor
		self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
		self.modelContainer = container

		downloadDelegate.setManager(self)
	}

	private var currentSettings: Settings? {
		let fetchDescriptor = FetchDescriptor<Settings>()
		do {
			return try modelContext.fetch(fetchDescriptor).first
		}
		catch {
			Logger.background.error(
				"Failed to fetch settings: \(error.localizedDescription)"
			)
			return nil
		}
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
		if let settings = await currentSettings {
			await login(password: settings.password, username: settings.username)
			// await fetchNotes(
		}
		else {
			Logger.background.error("Failed to get settings")
		}
	}

	func login(password: String, username: String) async {
		guard let loginURL = URL(string: "https://sync.nidus.cloud/login") else {
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
			"username=\(username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
		request.httpBody = formData.data(using: .utf8)
		let downloadTask = backgroundSession.downloadTask(with: request)
		downloadTask.resume()
		/*
		do {
			let (data, response) = try await backgroundSession.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse else {
                Logger.background.error("Invalid response")
				return
			}

			if httpResponse.statusCode == 200 {
				// Check if we received cookies
				let cookies = HTTPCookie.cookies(
					withResponseHeaderFields: httpResponse.allHeaderFields
						as! [String: String],
					for: loginURL
				)
				// Store cookies
				for cookie in cookies {
					cookieStorage.setCookie(cookie)
				}

				// Parse login response if needed
				if let responseString = String(data: data, encoding: .utf8) {
					print("Login response: \(responseString)")
				}

				self.isLoggedIn = true
			}
			else {
                Logger.background.error(
					"Login failed with status: \(httpResponse.statusCode)"
				)
			}

		}
		catch {
            Logger.background.error("Login error: \(error.localizedDescription)")
		}
        */
	}

}
