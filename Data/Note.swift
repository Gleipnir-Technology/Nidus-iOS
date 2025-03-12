//
//  Task.swift
//  Nidus
//
//  Created by Eli Ribble on 3/10/25.
//

import CoreLocation
import Foundation
import SwiftUI

enum NoteType: String, Codable {
	case info = "info"
}

struct Note: Hashable, Codable, Identifiable {
	var id: Int
	var title: String
	var type: NoteType

	var image: Image {
		switch type {
		case .info:
			return Image("NoteTypeIconInfo")
		}
	}
	private var coordinates: Coordinates
	var locationCoordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(
			latitude: coordinates.latitude,
			longitude: coordinates.longitude
		)
	}

	struct Coordinates: Hashable, Codable {
		var latitude: Double
		var longitude: Double
	}
}
