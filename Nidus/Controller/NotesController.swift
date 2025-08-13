import MapKit
import OSLog
import SwiftUI

/*
 Controller for the set of notes we're working with
 */
@Observable
class NotesController {
	var database: DatabaseController? = nil
	var model = NotesModel()
	var network: NetworkController? = nil

	private var region: MKCoordinateRegion = Initial.region

	func load() async throws {
		guard let database = self.database else {
			Logger.background.error("Database not set")
			return
		}
		try await database.connect()

		//loadFilters()
		//startUpdateCluster()
		let count = try database.service.notesCount()
		Logger.background.info("Notes count: \(count)")
	}

	// MARK - public interface
	func filterAdd(_ instance: FilterInstance) {
		model.filterInstances[instance.Name()] = instance
		onFilterChange()
	}

	func noteDelete() {
		Logger.foreground.warning("deleteNote not implemented")
	}

	func noteSave(isNew: Bool) {
		/*
        guard var notes = self.model.notes else {
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
         */
	}

	func onRegionChange(_ region: MKCoordinateRegion) {
		self.region = region
		self.calculateNotesToShow()
	}

	func saveAudioNote(_ recording: AudioRecording) throws {
		guard let database = self.database else {
			throw DatabaseError.notConnected
		}
		try database.service.insertAudioNote(recording)
		Logger.foreground.info("Saved recording \(recording.uuid)")
	}

	func savePictureNote(_ picture: UIImage, _ location: H3Cell?) throws {
		guard let database = self.database else {
			throw DatabaseError.notConnected
		}
		guard let png = picture.pngData() else {
			Logger.foreground.error("Failed to get PNG data for image")
			return
		}
		let uuid = UUID()
		let url = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		).appendingPathComponent("\(uuid).png")
		try png.write(to: url)
		try database.service.insertPictureNote(
			uuid: uuid,
			location: location,
			created: Date.now
		)
		Logger.foreground.info("Saved picture \(uuid)")
	}

	func startLoad(database: DatabaseController, network: NetworkController) {
		self.database = database
		self.network = network

		Task {
			do {
				try await self.load()
				Logger.background.info("Notes load complete")
			}
			catch {
				fatalError("Failed to load controllers: \(error)")
			}
		}
	}

	// MARK - private functions
	private func doError(_ message: String) {
		// TODO - raise this error properly to the UI layer
		Logger.foreground.error("UI-level error: \(message)")
	}
	private func doError(_ error: any Error) {
		// TODO - raise this error properly to the UI layer
		Logger.foreground.error("UI-level error: \(error)")
	}

	private func onFilterChange() {
		let asStrings: [String] = model.filterInstances.map { $1.toString() }
		UserDefaults.standard.set(asStrings, forKey: "filters")
		Logger.foreground.info("Saved filters \(asStrings)")
		calculateNotesToShow()
		startUpdateCluster()
	}

	private func calculateNotesToShow() {
		guard let database else {
			Logger.background.error("Database not ready yet")
			return
		}
		Task {
			do {
				let notes = try database.service.notesByRegion(self.region)
				model.mapAnnotations = notes.map { $0.value.mapAnnotation }
				model.notes = notes
				model.noteOverviews = notes.map { $0.value.overview }
			}
			catch {
				Logger.background.error("Failed to calculate notes: \(error)")
			}
		}
	}

	private func loadFilters() {
		let fs = UserDefaults.standard.stringArray(forKey: "filters") ?? []
		for f in fs {
			guard let filter: FilterInstance = FilterInstance.fromString(f) else {
				Logger.background.error("Failed to parse filter string: \(f)")
				continue
			}
			self.model.filterInstances[filter.Name()] = filter
		}
	}
	private func saveNoteUpdates(_ response: NotesResponse) async {
		/*
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
            notes.startLoadNotesFromDatabase()
            notes.startUpdateCluster()
            Logger.background.info("Done saving API response")
        }
        catch {
            Logger.background.error("Failed to handle API response: \(error)")
        }
        */
	}

	private func shouldShow(_ note: AnyNote) -> Bool {
		for filter in model.filterInstances.values {
			if !filter.AllowsNote(note) {
				return false
			}
		}
		if note.coordinate.latitude < model.currentRegion.minLatitude
			|| note.coordinate.longitude < model.currentRegion.minLongitude
			|| note.coordinate.latitude > model.currentRegion.maxLatitude
			|| note.coordinate.longitude > model.currentRegion.maxLongitude
		{
			return false
		}
		return true
	}

	func startAudioUpload(_ uuid: UUID? = nil) {
		Task {
			guard let network = self.network
			else {
				Logger.background.error(
					"Network controller is null when doing audio upload"
				)
				return
			}
			guard let database = self.database
			else {
				Logger.background.error(
					"Database controlleris null when doing audio upload"
				)
				return
			}
			let toUpload: [UUID] =
				uuid != nil ? [uuid!] : try database.service.audioThatNeedsUpload()
			for audio in toUpload {
				try await network.service.uploadAudio(audio)
				try database.service.audioUploaded(audio)
				Logger.background.info(
					"Uploaded audio \(audio.uuidString)"
				)
			}
		}
	}

	func startImageUpload(_ uuid: UUID? = nil) {
		Task {
			guard let network = self.network
			else {
				Logger.background.error(
					"Background network manager is null when doing image upload"
				)
				return
			}
			guard let database = self.database
			else {
				Logger.background.error(
					"Database controlleris null when doing audio upload"
				)
				return
			}
			let toUpload: [UUID] =
				uuid != nil
				? [uuid!] : try database.service.picturesThatNeedUpload()

			for image in toUpload {
				try await network.service.uploadImage(image)
				try database.service.pictureUploaded(image)
				Logger.background.info(
					"Uploaded image \(image.uuidString)"
				)
			}
		}

	}

	/* private */
	func startNoteDownload() {
		Task {
			guard let network = network else {
				Logger.background.error(
					"Background network manager is null when doing note download"
				)
				return
			}
			let noteUpdates = try await network.service.fetchNoteUpdates()
			await saveNoteUpdates(noteUpdates)
		}
	}

	func startNoteUpload(_ note: NidusNote? = nil) {
		Task {
			do {
				guard let network = network else {
					Logger.background.error(
						"Background network manager is null when doing note download"
					)
					return
				}
				guard let database = self.database
				else {
					Logger.background.error(
						"Background network manager is null when doing image upload"
					)
					return
				}
				let toUpload: [NidusNote] =
					note != nil
					? [note!] : try database.service.notesThatNeedUpload()
				// Upload notes first so that the back office gets them fastest
				for note in toUpload {
					try await network.service.uploadNote(note)
					note.uploaded = Date.now
					try database.service.noteUpdate(note)
					Logger.background.info(
						"Updated note \(note.id) to uploaded"
					)
				}
			}
			catch {
				doError(error)
			}
		}
	}

	func startUpdateCluster() {
		// TODO - fix
		/*
		Task {
			await cluster.onNoteChanges(
				notes: notesToShow,
				mapSize: mapSize,
				region: currentRegion
			)
		}*/
	}

}

class NotesControllerPreview: NotesController {
	init(model: NotesModel = NotesModel()) {
		super.init()
		self.model = model
	}
}
