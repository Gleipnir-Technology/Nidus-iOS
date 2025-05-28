import OSLog
//
//  ModelActor.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/27/25.
//
import SwiftData
import SwiftUI

/*
 https://www.massicotte.org/model-actor
@MainActor
func makeMainModelActor() -> MyModelActor {
    MyModelActor(modelContainer: .shared)
}

func makeBackgroundModelActor() async -> MyModelActor {
    MyModelActor(modelContainer: .shared)
}

@ModelActor
actor MyModelActor {
    func hello() {
        print("Hi there!")
    }
}

extension ModelActor {
    func withContext<T>(
        _ block: (ModelContext) -> T
    ) -> T {
        block(modelContext)
    }
}
*/

/* from
 https://useyourloaf.com/blog/swiftdata-background-tasks/
 */

@ModelActor public actor BackgroundModelActor {
	func triggerFetch() async throws {
		let backgroundNetworkManager = BackgroundNetworkManager(with: modelContainer)
		try await backgroundNetworkManager.startBackgroundDownload()
	}
}
