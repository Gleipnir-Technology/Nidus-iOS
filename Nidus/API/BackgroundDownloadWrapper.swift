import Foundation
import OSLog
import Sentry
import UIKit

enum AuthError: Error {
	case invalidCredentials
	case noCredentials

	static func fromErrorCode(_ code: String) -> AuthError? {
		switch code {
		case "no-credentials":
			return .noCredentials
		case "invalid-credentials":
			return .invalidCredentials
		default: return nil
		}
	}
}

class BackgroundDownloadWrapper: NSObject, ObservableObject, URLSessionDownloadDelegate,
	URLSessionTaskDelegate, URLSessionDelegate
{
	private var backgroundSession: URLSession!
	private var continuations: [URLSessionTask: CheckedContinuation<URL, Error>] = [:]
	private let cookieStorage: HTTPCookieStorage
	private var password: String = ""
	private var progressHandlers: [URLSessionTask: (any ProgressUpdate) -> Void] = [:]
	private var username: String = ""

	override init() {
		self.cookieStorage = HTTPCookieStorage.shared
		super.init()
		let config = URLSessionConfiguration.background(
			withIdentifier: "technology.gleipnir.nidus-notes.download-session"
		)
		config.timeoutIntervalForRequest = 10
		config.timeoutIntervalForResource = 120
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
		progressHandler: @escaping (any ProgressUpdate) -> Void = { _ in }
	) async throws -> URL {
		return try await withCheckedThrowingContinuation {
			(continuation: CheckedContinuation<URL, Error>) in
			let task = backgroundSession.downloadTask(with: request)
			continuations[task] = continuation
			progressHandlers[task] = progressHandler
			Logger.background.info(
				"New network request to \(request.url?.absoluteString ?? "unknown")"
			)
			task.resume()
		}
	}

	func setAuthentication(password: String, username: String) {
		self.password = password
		self.username = username
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

		Logger.background.info(
			"Finished downloading request to \(downloadTask.originalRequest?.url?.absoluteString ?? "unknown")"
		)
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
					if statusCode == 401 {
						// See if we have a header identifying the specific issue
						if let authErrorCode = httpResponse.value(
							forHTTPHeaderField:
								"WWW-Authenticate-Error"
						) {
							Logger.background.error(
								"Authentication error: \(authErrorCode)"
							)
							continuation.resume(
								throwing: AuthError.fromErrorCode(
									authErrorCode
								)
									?? URLError(
										URLError.Code(
											rawValue:
												statusCode
										)
									)
							)
							return
						}
						else {
							Logger.background.error(
								"Server didn't provide a specific authentication error code"
							)
						}
					}
					continuation.resume(
						throwing: URLError(
							URLError.Code(rawValue: statusCode)
						)
					)
				}
			}

		}
		catch {
			SentrySDK.capture(error: error)
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

	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didSendBodyData bytesSent: Int64,
		totalBytesSent: Int64,
		totalBytesExpectedToSend: Int64
	) {
		let progress = UploadProgress(
			bytesSent: bytesSent,
			totalBytesSent: totalBytesSent,
			totalBytesExpectedToSend: totalBytesExpectedToSend,
			progress: totalBytesExpectedToSend > 0
				? Double(totalBytesSent) / Double(totalBytesExpectedToSend) : 0
		)
		progressHandlers[task]?(progress)
	}

	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didReceive: URLAuthenticationChallenge,
		completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	) {
		// If we have some kind of error this isn't actually an auth challenge, but rather
		// a failure on our configuration
		guard let response = task.response else {
			Logger.background.warning(
				"Unable to get response from task on authentication challenge for \(task.originalRequest?.url?.absoluteString ?? "unknown URL")"
			)
			completionHandler(
				.cancelAuthenticationChallenge,
				nil
			)
			return
		}
		if let httpResponse = response as? HTTPURLResponse {
			// If we can get an error code, then there is definitely something wrong on our side, so cancel the request
			if let authErrorCode = httpResponse.value(
				forHTTPHeaderField:
					"WWW-Authenticate-Error"
			) {
				Logger.background.info(
					"Got auth error '\(authErrorCode)', ending request"
				)
				completionHandler(.cancelAuthenticationChallenge, nil)
				return
			}
		}
		else {
			Logger.background.info("Unable to coerce to HTTPURLResponse")
		}

		// Otherwise, keep going and we'll add credential information
		completionHandler(
			.useCredential,
			URLCredential(
				user: self.username,
				password: self.password,
				persistence: .forSession
			)
		)
	}
	func urlSession(_ session: URLSession, taskIsWaitingForConnectivity: URLSessionTask) {
		Logger.background.warning("Waiting for connectivity")
	}

	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		willBeginDelayedRequest: URLRequest,
		completionHandler: (URLSession.DelayedRequestDisposition, URLRequest?) -> Void
	) {
		Logger.background.info(
			"Begin task for \(task.originalRequest?.url?.absoluteString ?? "unknown")"
		)
		completionHandler(.continueLoading, nil)
	}
	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		needNewBodyStream: (InputStream?) -> Void
	) {
		Logger.background.warning("need new body stream...?")
	}
	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		willPerformHTTPRedirection: HTTPURLResponse,
		newRequest: URLRequest,
		completionHandler: (URLRequest?) -> Void
	) {
		Logger.background.warning("Need redirect")
	}
	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didFinishCollecting: URLSessionTaskMetrics
	) {
		Logger.background.info(
			"metrics for \(task.originalRequest?.url?.absoluteString ?? "unknown"): \(didFinishCollecting.taskInterval.duration)"
		)
		/*if let response = task.response as? HTTPURLResponse {
            for (k, v) in response.allHeaderFields {
                Logger.background.info("Header: \(String(describing: k))=\(String(describing: v))")
            }
        }*/
	}
	func urlSession(_ session: URLSession, didCreateTask: URLSessionTask) {

		Logger.background.info(
			"Created task for \(didCreateTask.originalRequest?.url?.absoluteString ?? "unknown")"
		)
	}
	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didReceiveInformationalResponse: HTTPURLResponse
	) {

		Logger.background.info("got informational response")
	}
	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		needNewBodyStreamFrom: Int64,
		completionHandler: (InputStream?) -> Void
	) {

		Logger.background.info("need body stream from")
	}
	func urlSession(_ session: URLSession, didBecomeInvalidWithError: (any Error)?) {
		Logger.background.info("became invalid")
	}
	func urlSessionDidFinishEvents(forBackgroundURLSession: URLSession) {
		//Logger.background.info("Finished.")
	}

	private func permanentURL(for originalURL: URL) -> URL {
		let documentsPath = FileManager.default.urls(
			for: .documentDirectory,
			in: .userDomainMask
		)[0]
		let filename = originalURL.lastPathComponent
		return documentsPath.appendingPathComponent(filename)
	}

}

protocol ProgressUpdate {
	var progress: Double { get }
}

struct DownloadProgress: ProgressUpdate {
	let bytesWritten: Int64
	let totalBytesExpected: Int64
	let progress: Double
}

struct UploadProgress: ProgressUpdate {
	let bytesSent: Int64
	let totalBytesSent: Int64
	let totalBytesExpectedToSend: Int64
	let progress: Double
}
