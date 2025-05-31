//
//  ModelActor.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/27/25.
//
import SwiftUI

/* from
 https://useyourloaf.com/blog/swiftdata-background-tasks/
 */

public actor BackgroundModelActor {
	func triggerFetch(_ db: Database) async throws {
		let backgroundNetworkManager = BackgroundNetworkManager(db)
		try await backgroundNetworkManager.startBackgroundDownload()
	}
}
