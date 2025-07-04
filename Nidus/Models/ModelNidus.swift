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
class ModelNidus {
	var backgroundNetworkManager: BackgroundNetworkManager?
	var backgroundNetworkProgress: Double = 0.0
	var backgroundNetworkState: BackgroundNetworkState = .idle
	var currentRegion: MKCoordinateRegion
	var cluster: NotesCluster = NotesCluster()
	var database: Database
	var filterInstances: [String: FilterInstance]
	var errorMessage: String?
	var locationDataManager = LocationDataManager()
	var mapSize: CGSize = .zero
	var noteBuffer: ModelNoteBuffer = ModelNoteBuffer()
	var notes: [UUID: AnyNote]? = nil
	var notesToShow: [AnyNote]? = nil
	var toast: ModelToast = ModelToast()

	init() {
		self.currentRegion = .visalia
		self.filterInstances = [:]
		self.database = Database()!
		do {
			try self.database.migrateIfNeeded()
		}
		catch {
			fatalError("Failed to run database migrations: \(error)")
		}
		loadCurrentRegion()
		loadFilters()
		startLoadNotesFromDatabase()
		startUpdateCluster()
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
			guard let filter: FilterInstance = FilterInstance.fromString(f) else {
				Logger.background.error("Failed to parse filter string: \(f)")
				continue
			}
			self.filterInstances[filter.Name()] = filter
		}
	}
	private func calculateNotesToShow() {
		// we haven't loaded up the notes yet
		guard let notes = notes else {
			notesToShow = nil
			return
		}
		notesToShow = []
		for (_, note) in notes {
			if shouldShow(note) {
				notesToShow!.append(note)
			}
		}
	}

	func createBackgroundNetworkManager() {
		self.backgroundNetworkManager = BackgroundNetworkManager(
			onError: onError,
			onProgress: onNetworkProgress
		)
		startNoteDownload()
		startAudioUpload()
		startImageUpload()
		startNoteUpload()
	}

	func onDeleteNote() {
		guard let note = self.noteBuffer.note else {
			Logger.foreground.error(
				"Programmer error: Tried to delete note, but note buffer is empty"
			)
			return
		}
		guard var notes = self.notes else {
			Logger.foreground.info(
				"User requested note deletion before notes are loaded from the database. Impressive. Probably not an issue."
			)
			return
		}
		do {
			try database.deleteNote(note)
			notes.removeValue(forKey: note.id)
			notesToShow!.removeAll(where: { return note.id == $0.id })
			startNoteUpload(note)
		}
		catch {
			Logger.foreground.error("Failed to delete note \(note.id): \(error)")
		}
	}
	func onResetChanges() {
		noteBuffer.Reset(noteBuffer.note)
	}
	func onSaveNote(isNew: Bool) {
		guard var notes = self.notes else {
			Logger.foreground.info(
				"User requested saving a note before any notes are loaded. Seems unlikely."
			)
			return
		}
		let note = noteBuffer.toNote()
		Logger.foreground.info("Saving \(isNew ? "new" : "old") note \(note.id)")
		if noteBuffer.location == nil {
			Logger.foreground.info("Can't save note, it has no location")
			errorMessage = "This note needs a location"
			toast.showLocationToast = true
			return
		}

		do {
			for image in note.images {
				try image.save()
			}
		}
		catch {
			errorMessage = "Failed to save images: \(error)"
		}
		do {
			// Clear the "uploaded" field so that this note will be uploaded again
			note.uploaded = nil
			_ = try database.upsertNidusNote(note)
		}
		catch {
			errorMessage = "Failed to upsert note: \(error)"
		}
		if isNew {
			notes[note.id] = AnyNote(note)
			calculateNotesToShow()
		}
		startNoteUpload(note)
		for audioRecording in note.audioRecordings {
			startAudioUpload(audioRecording.uuid)
		}
		for image in note.images {
			startImageUpload(image.uuid)
		}
		toast.showSavedToast = true
	}

	func onError(_ error: Error) {
		errorMessage = "\(error)"
	}
	func onFilterAdded(_ instance: FilterInstance) {
		filterInstances[instance.Name()] = instance
		onFilterChange()
	}
	func onFilterChange() {
		let asStrings: [String] = filterInstances.map { $1.toString() }
		UserDefaults.standard.set(asStrings, forKey: "filters")
		Logger.foreground.info("Saved filters \(asStrings)")
		calculateNotesToShow()
		startUpdateCluster()
	}
	func onMapPositionChange(region: MKCoordinateRegion) {
		currentRegion = region
		calculateNotesToShow()
		startUpdateCluster()
		saveCurrentRegion()
		Logger.foreground.info(
			"Set current location limits to \(String(describing: region))"
		)
	}

	func onMapSizeChange(_ size: CGSize) {
		self.mapSize = size
		calculateNotesToShow()
	}
	func onNetworkProgress(_ progress: Double) {
		self.backgroundNetworkProgress = progress
	}

	func onNetworkStateChange(_ state: BackgroundNetworkState) {
		self.backgroundNetworkState = state
	}

	func startAudioUpload(_ uuid: UUID? = nil) {
		Task {
			guard let backgroundNetworkManager = self.backgroundNetworkManager
			else {
				Logger.background.error(
					"Background network manager is null when doing audio upload"
				)
				return
			}
			let toUpload: [UUID] =
				uuid != nil ? [uuid!] : try database.audioThatNeedsUpload()
			for audio in toUpload {
				try await backgroundNetworkManager.uploadAudio(
					currentSettings,
					audio
				)
				try database.audioUploaded(audio)
				Logger.background.info(
					"Uploaded audio \(audio.uuidString)"
				)
			}
		}
	}

	func startImageUpload(_ uuid: UUID? = nil) {
		Task {
			guard let backgroundNetworkManager = self.backgroundNetworkManager
			else {
				Logger.background.error(
					"Background network manager is null when doing image upload"
				)
				return
			}
			let toUpload: [UUID] =
				uuid != nil ? [uuid!] : try database.imagesThatNeedUpload()

			for image in toUpload {
				try await backgroundNetworkManager.uploadImage(
					currentSettings,
					image
				)
				try database.imageUploaded(image)
				Logger.background.info(
					"Uploaded image \(image.uuidString)"
				)
			}
		}

	}

	func startNoteDownload() {
		Task {
			guard let backgroundNetworkManager = self.backgroundNetworkManager else {
				Logger.background.error(
					"Background network manager is null when doing note download"
				)
				return
			}
			backgroundNetworkState = .idle
			let noteUpdates = try await backgroundNetworkManager.fetchNoteUpdates(
				currentSettings
			)
			backgroundNetworkState = .savingData
			await saveNoteUpdates(noteUpdates)
			backgroundNetworkState = .idle
		}
	}

	func startNoteUpload(_ note: NidusNote? = nil) {
		Task {
			do {
				guard let backgroundNetworkManager = self.backgroundNetworkManager
				else {
					Logger.background.error(
						"Background network manager is null when doing note upload"
					)
					return
				}
				let toUpload: [NidusNote] =
					note != nil ? [note!] : try database.notesThatNeedUpload()
				// Upload notes first so that the back office gets them fastest
				for note in toUpload {
					try await backgroundNetworkManager.uploadNote(
						currentSettings,
						note
					)
					note.uploaded = Date.now
					try database.noteUpdate(note)
					Logger.background.info(
						"Updated note \(note.id) to uploaded"
					)
				}
			}
			catch {
				onError(error)
			}
		}
	}

	private func loadCurrentRegion() {
		guard let regionString = UserDefaults.standard.string(forKey: "currentRegion")
		else {
			return
		}
		if regionString == "" {
			return
		}
		let scanner = Scanner(string: regionString)
		guard let latitude = scanner.scanDouble() else {
			return
		}
		_ = scanner.scanCharacter()  // drop the ","
		guard let longitude = scanner.scanDouble() else {
			return
		}
		_ = scanner.scanCharacter()  // drop the ","
		guard let latitudeDelta = scanner.scanDouble() else {
			return
		}
		_ = scanner.scanCharacter()  // drop the ","
		guard let longitudeDelta = scanner.scanDouble() else {
			return
		}
		self.currentRegion = .init(
			center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
			span: MKCoordinateSpan(
				latitudeDelta: latitudeDelta,
				longitudeDelta: longitudeDelta
			)
		)
		let r = String(
			format: "center x %f, center y %f, span latitude %f, span longitude %f",
			currentRegion.center.latitude,
			currentRegion.center.longitude,
			currentRegion.span.latitudeDelta,
			currentRegion.span.longitudeDelta
		)
		Logger.foreground.info("Loaded current map region \(r)")
	}

	private func saveCurrentRegion() {
		let regionString = String(
			format: "%f,%f,%f,%f",
			currentRegion.center.latitude,
			currentRegion.center.longitude,
			currentRegion.span.latitudeDelta,
			currentRegion.span.longitudeDelta
		)
		UserDefaults.standard.set(regionString, forKey: "currentRegion")
	}

	private func saveNoteUpdates(_ response: NotesResponse) async {
		do {
			Logger.background.info("Begin saving API response")
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
			startLoadNotesFromDatabase()
			startUpdateCluster()
			Logger.background.info("Done saving API response")
		}
		catch {
			Logger.background.error("Failed to handle API response: \(error)")
		}
	}

	private func shouldShow(_ note: AnyNote) -> Bool {
		for filter in filterInstances.values {
			if !filter.AllowsNote(note) {
				return false
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

	private func startLoadNotesFromDatabase() {
		Task {
			do {
				notes = try database.notes()
				calculateNotesToShow()
			}
			catch {
				errorMessage = "Error loading notes: \(error)"
			}
		}
	}

	private func startUpdateCluster() {
		guard let notesToShow = self.notesToShow else {
			Logger.background.warning(
				"Cannot update cluster because notesToShow is nil"
			)
			return
		}
		Task {
			await cluster.onNoteChanges(
				notes: notesToShow,
				mapSize: mapSize,
				region: currentRegion
			)
		}
	}

}
