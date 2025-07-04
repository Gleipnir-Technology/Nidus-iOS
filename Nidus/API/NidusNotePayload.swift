//
//  NidusNotePayload.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/3/25.
//
import Foundation

struct NidusNotePayload: Codable {
	let audio: [AudioPayload]
	let images: [ImagePayload]
	let location: Location
	let text: String
	let timestamp: Date
	let uuid: UUID
}
