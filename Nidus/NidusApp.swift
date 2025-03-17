//
//  NidusApp.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//
import CoreLocation
import SwiftUI

@main
struct NidusApp: App {
	@State private var modelData = ModelData()

	var body: some Scene {
		WindowGroup {
			ContentView().environment(modelData)
		}
	}
}
