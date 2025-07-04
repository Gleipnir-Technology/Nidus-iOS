//
//  NidusNotePayload.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/3/25.
//
import Foundation

struct NidusNotePayload: Codable {
	let uuid: UUID
	let timestamp: Date
	let audio: [UUID]
	let images: [UUID]
	let location: Location
	let text: String
}
