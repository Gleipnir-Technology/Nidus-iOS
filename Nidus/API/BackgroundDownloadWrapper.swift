//
//  BackgroundDownloadWrapper.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/3/25.
//

import Foundation
import OSLog
import UIKit

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
