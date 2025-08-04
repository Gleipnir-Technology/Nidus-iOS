import SwiftUI

@Observable
class DatabaseController {
	// TODO: make this private eventually
	var service: DatabaseService

	init() {
		self.service = DatabaseService()
	}

	func connect() async throws {
		try service.migrateIfNeeded()
	}
}
