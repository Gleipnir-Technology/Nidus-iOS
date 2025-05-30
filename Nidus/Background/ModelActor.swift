//
//  ModelActor.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/27/25.
//
import SwiftData
import SwiftUI

/* from
 https://useyourloaf.com/blog/swiftdata-background-tasks/
 */

@ModelActor public actor BackgroundModelActor {
	func triggerFetch(_ db: Database) async throws {
		let backgroundNetworkManager = BackgroundNetworkManager(db)
		try await backgroundNetworkManager.startBackgroundDownload()
	}
}
