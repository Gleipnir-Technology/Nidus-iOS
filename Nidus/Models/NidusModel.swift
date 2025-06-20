//
//  NidusModel.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/3/25.
//
import MapKit
import OSLog
import SwiftUI

@Observable
class NidusModel {
	var backgroundNetworkManager: BackgroundNetworkManager?
	var backgroundNetworkProgress: Double = 0.0
	var backgroundNetworkState: BackgroundNetworkState = .idle
	var currentRegion: MKCoordinateRegion = MKCoordinateRegion.visalia
	var cluster: NotesCluster = NotesCluster()
	var database: Database
	var filters: Set<Filter>
	var errorMessage: String?
	var notes: [UUID: AnyNote] = [:]

	init() {
		self.filters = []
		self.database = Database()!
		loadFilters()
		triggerUpdateComplete()
	}

	private var currentSettings: Settings {
		let password = UserDefaults.standard.string(forKey: "password") ?? ""
		let url =
			UserDefaults.standard.string(forKey: "sync-url")
			?? "https://sync.nidus.cloud"
		let username = UserDefaults.standard.string(forKey: "username") ?? ""
		return Settings(password: password, URL: url, username: username)
	}

	private func loadFilters() {
		let fs = UserDefaults.standard.stringArray(forKey: "filters") ?? []
		for f in fs {
			guard let filter: Filter = Filter.fromString(f) else {
				Logger.background.error("Failed to parse filter string: \(f)")
				continue
			}
			self.filters.insert(filter)
		}
	}
	func maybeAddFilter(_ filter: Filter) {
		var toRemove: Filter? = nil
		for f in filters {
			if f.type == filter.type {
				toRemove = f
			}
		}
		if toRemove != nil {
			filters.remove(toRemove!)
		}
		// Some filters require others. Add both
		if filter.type == .habitat {
			maybeAddFilter(
				Filter(type: .category, value: NoteCategory.mosquitoSource.name)
			)
		}
		filters.insert(filter)
	}
	var notesToShow: [AnyNote] {
		var toShow: [AnyNote] = []
		for (_, note) in notes {
			if shouldShow(note) {
				toShow.append(note)
			}
		}
		return toShow
	}

	func onAPIResponse(_ response: APIResponse) {
		do {
			self.backgroundNetworkProgress = 0.0
			let totalRecords =
				response.requests.count + response.sources.count
				+ response.traps.count
			var i = 0
			for r in response.requests {
				try database.upsertServiceRequest(r)
				i += 1
				if i % 100 == 0 {
					self.backgroundNetworkProgress =
						Double(i) / Double(totalRecords)
				}
			}
			for s in response.sources {
				try database.upsertSource(s)
				i += 1
				if i % 100 == 0 {
					self.backgroundNetworkProgress =
						Double(i) / Double(totalRecords)
				}
			}
			triggerUpdateComplete()
			Logger.background.info("Done saving response")
		}
		catch {
			Logger.background.error("Failed to handle API response: \(error)")
		}
	}

	func onNetworkProgress(_ progress: Double) {
		self.backgroundNetworkProgress = progress
	}

	func onNetworkStateChange(_ state: BackgroundNetworkState) {
		self.backgroundNetworkState = state
	}

	func setFilters(_ filters: Set<Filter>) {
		let asStrings: [String] = filters.map { $0.toString() }
		UserDefaults.standard.set(asStrings, forKey: "filters")
		Logger.foreground.info("Saved filters \(asStrings)")
	}

	func setPosition(region: MKCoordinateRegion) {
		currentRegion = region
		Logger.foreground.info(
			"Set current location limits to \(String(describing: region))"
		)
	}

	private func shouldShow(_ note: AnyNote) -> Bool {
		for filter in filters {
			switch filter.type {
			case .category:
				if note.categoryName != filter.stringValue {
					return false
				}
			case .habitat:
				guard let asSource: MosquitoSource = note.asMosquitoSource() else {
					return false
				}
				if asSource.habitat != filter.stringValue {
					return false
				}
			default:
				continue
			}
		}
		if note.coordinate.latitude < currentRegion.minLatitude
			|| note.coordinate.longitude < currentRegion.minLongitude
			|| note.coordinate.latitude > currentRegion.maxLatitude
			|| note.coordinate.longitude > currentRegion.maxLongitude
		{
			return false
		}
		return true
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
			onProgress: onNetworkProgress,
			onStateChange: onNetworkStateChange
		)
		Task {
			do {
				try await backgroundNetworkManager!.startBackgroundDownload(
					currentSettings
				)
			}
			catch {
				Logger.background.error(
					"Failed to trigger fetch \(error)"
				)
			}
		}
	}
}
