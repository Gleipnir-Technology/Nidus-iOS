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
	func triggerFetch(_ model: NidusModel) async throws {
		let backgroundNetworkManager = BackgroundNetworkManager(model)
		try await backgroundNetworkManager.startBackgroundDownload()
	}
}
