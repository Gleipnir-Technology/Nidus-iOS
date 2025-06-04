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
	var currentRegion: MKCoordinateRegion = MKCoordinateRegion.visalia
	var cluster: NotesCluster = NotesCluster()
	var database: Database = Database()
	var errorMessage: String?
	var isDownloading = false
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
		Task {
			let actor = BackgroundModelActor()
			do {
				isDownloading = true
				try await actor.triggerFetch(self)
			}
			catch {
				Logger.background.error(
					"Failed to trigger fetch \(error.localizedDescription)"
				)
			}
		}
	}

	func upsertServiceRequest(_ sr: ServiceRequest) {
		do {
			try database.upsertServiceRequest(sr)
		}
		catch {
			Logger.background.error("Failed to upsert service request: \(error)")
		}
	}
	func upsertSource(_ source: MosquitoSource) {
		do {
			try database.upsertSource(source)
		}
		catch {
			Logger.background.error("Failed to upsert source: \(error)")
		}
	}
}
