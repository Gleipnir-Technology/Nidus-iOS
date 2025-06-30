//
//  AudioRecording.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/29/25.
//

import Foundation
import OSLog

class AudioRecording: Equatable {
	var created: Date
	var duration: TimeInterval
	var transcription: String?
	var uuid: UUID

	init(
		created: Date,
		duration: TimeInterval,
		transcription: String? = nil,
		uuid: UUID = UUID()
	) {
		self.created = created
		self.duration = duration
		self.transcription = transcription
		self.uuid = uuid
	}

	var url: URL {
		return AudioRecording.url(for: self.uuid)
	}

	func save() throws {
		/*guard let image = self.image else {
            throw ImageError.saveFailure("Image is nil")
        }
        guard let png = image.pngData() else {
            throw ImageError.saveFailure("Failed to get PNG image data")
        }
        try png.write(to: self.url)
         */
		Logger.foreground.info("Saved audio recording to \(self.url)")
	}

	static func url(for uuid: UUID) -> URL {
		let supportURL = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		)
		return supportURL.appendingPathComponent("\(uuid).m4a")
	}
	static func == (lhs: AudioRecording, rhs: AudioRecording) -> Bool {
		return lhs.created == rhs.created && lhs.duration == rhs.duration
			&& lhs.transcription == rhs.transcription && lhs.uuid == rhs.uuid
	}
}
