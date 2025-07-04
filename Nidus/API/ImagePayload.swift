//
//  ImagePayload.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 7/3/25.
//
import Foundation

struct ImagePayload: Codable {
	let created: Date
	let deleted: Date?
	let size_x: Int
	let size_y: Int
	let uuid: UUID
}
