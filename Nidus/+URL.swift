import Foundation

extension URL {
	/// A unique output location to write a movie.
	static var movieFileURL: URL {
		URL.temporaryDirectory.appending(component: UUID().uuidString)
			.appendingPathExtension(for: .quickTimeMovie)
	}
}
