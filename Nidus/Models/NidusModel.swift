//
//  NidusModel.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/3/25.
//
import MapKit
import OSLog

@Observable
class NidusModel {
	var backgroundNetworkManager: BackgroundNetworkManager?
	var backgroundNetworkState: BackgroundNetworkState = .idle
	var currentRegion: MKCoordinateRegion = MKCoordinateRegion.visalia
	var cluster: NotesCluster = NotesCluster()
	var database: Database = Database()
	var errorMessage: String?
	var notes: [UUID: AnyNote] = [:]

	init() {
		triggerUpdateComplete()
	}

	var notesToShow: [AnyNote] {
		var toShow: [AnyNote] = []
		for (_, note) in notes {
			if note.coordinate.latitude > currentRegion.minLatitude
				&& note.coordinate.longitude > currentRegion.minLatitude
				&& note.coordinate.latitude < currentRegion.maxLatitude
				&& note.coordinate.longitude < currentRegion.maxLongitude
			{
				toShow.append(note)
			}
		}
		return toShow
	}

	func onAPIResponse(_ response: APIResponse) {
		do {
			Logger.background.info("Saving API response")
			Logger.background.info("Sources \(response.sources.count)")
			Logger.background.info("Requests \(response.requests.count)")
			Logger.background.info("Traps \(response.traps.count)")
			var i = 0
			for r in response.requests {
				try database.upsertServiceRequest(r)
				i += 1
				if i % 1000 == 0 {
					Logger.background.info("Request \(i)")
				}
			}
			i = 0
			for s in response.sources {
				try database.upsertSource(s)
				i += 1
				if i % 1000 == 0 {
					Logger.background.info("Source \(i)")
				}
			}
			triggerUpdateComplete()
			Logger.background.info("Done saving response")
		}
		catch {
			Logger.background.error("Failed to handle API response: \(error)")
		}
	}

	func onNetworkStateChange(_ state: BackgroundNetworkState) {
		self.backgroundNetworkState = state
	}

	func setPosition(region: MKCoordinateRegion) {
		currentRegion = region
		Logger.foreground.info(
			"Set current location limits to \(String(describing: region))"
		)
	}

	func triggerUpdateComplete() {
		do {
			notes = try database.notes()
			Task {
				await cluster.setNotes(Array(notes.values))
			}
		}
		catch {
			errorMessage = "Error loading notes: \(error)"
		}
	}

	func triggerBackgroundFetch() {
		self.backgroundNetworkManager = BackgroundNetworkManager(
			onAPIResponse: onAPIResponse,
			onStateChange: onNetworkStateChange
		)
		Task {
			do {
				try await backgroundNetworkManager!.startBackgroundDownload()
			}
			catch {
				Logger.background.error(
					"Failed to trigger fetch \(error)"
				)
			}
		}
	}
}
