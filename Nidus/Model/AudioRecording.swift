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
	var locations: [H3Cell]
	var transcription: String?
	var uuid: UUID

	init(
		created: Date,
		duration: TimeInterval,
		locations: [H3Cell] = [],
		transcription: String? = nil,
		uuid: UUID = UUID()
	) {
		self.created = created
		self.duration = duration
		self.locations = locations
		self.transcription = transcription
		self.uuid = uuid
	}

	var url: URL {
		return AudioRecording.url(self.uuid)
	}

	static func url(_ uuid: UUID) -> URL {
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
