//
//  AudioRecordingPayload.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/3/25.
//

import Foundation

struct AudioPayload: Codable {
	let created: Date
	let deleted: Date?
	let duration: Double
	let transcription: String?
	let uuid: UUID
}
