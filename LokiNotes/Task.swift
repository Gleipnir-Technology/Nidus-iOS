	//
//  Task.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/10/25.
//

import Foundation
import SwiftUI

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
    
    struct Coordinates: Hashable, Codable {
        var latitude: Double
        var longitude: Double
    }
}
