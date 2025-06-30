//
//  Image.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/29/25.
//
import Foundation
import OSLog
import SwiftUI

enum ImageError: Error {
	case saveFailure(String)
}

class NoteImage {
	var created: Date
	var image: UIImage?
	var uuid: UUID

	init(created: Date = Date.now, uuid: UUID = UUID()) {
		self.created = created
		self.image = nil
		self.uuid = uuid
	}

	init(_ uiimage: UIImage) {
		self.created = Date.now
		self.image = uiimage
		self.uuid = UUID()
	}

	private var url: URL {
		let supportURL = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		)
		return supportURL.appendingPathComponent("\(uuid).png")
	}

	func save() throws {
		guard let image = self.image else {
			throw ImageError.saveFailure("Image is nil")
		}
		guard let png = image.pngData() else {
			throw ImageError.saveFailure("Failed to get PNG image data")
		}
		try png.write(to: self.url)
		Logger.foreground.info("Saved image to \(self.url)")
	}

	func toUIImage() -> UIImage? {
		if image != nil {
			return image
		}
		do {
			let imagedata = try Data(contentsOf: url)
			guard let image = UIImage(data: imagedata) else {
				Logger.foreground.error("Failed to load image from \(self.url)")
				return nil
			}
			return image
		}
		catch {
			Logger.foreground.error("Failed to read image from \(self.url): \(error)")
			return nil
		}
	}
}
