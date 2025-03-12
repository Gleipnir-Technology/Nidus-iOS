//
//  LokiNotesApp.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftUI

@main
struct LokiNotesApp: App {
    @State private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(modelData)
        }
    }
}
