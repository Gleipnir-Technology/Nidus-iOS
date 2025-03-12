	//
//  Task.swift
//  Nidus
//
//  Created by Eli Ribble on 3/10/25.
//

import Foundation
import SwiftUI
import CoreLocation

enum TaskType: String, Codable {
    case info = "info"
}

struct Task: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var type: TaskType
    
    var image: Image {
        switch(type) {
           case .info:
            return Image("TaskTypeIconInfo")
        }
    }
    private var coordinates: Coordinates
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude)
    }
    
    struct Coordinates: Hashable, Codable {
        var latitude: Double
        var longitude: Double
    }
}
