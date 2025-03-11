	//
//  Task.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/10/25.
//

import Foundation
import SwiftUI

struct Task: Hashable, Codable {
    var id: Int
    var title: String
    
    private var coordinates: Coordinates
    
    struct Coordinates: Hashable, Codable {
        var latitude: Double
        var longitude: Double
    }
}
