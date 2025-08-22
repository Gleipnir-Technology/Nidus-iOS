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

	// MARK - public functions
	func load() async throws {
		guard let database = self.database else {
			Logger.background.error("Database not set")
			return
		}
		try await database.connect()

		//loadFilters()
		let count = try database.service.notesCount()
		Logger.background.info("Database loaded. Notes count: \(count)")
	}

	func filterAdd(_ instance: FilterInstance) {
		model.filterInstances[instance.Name()] = instance
		onFilterChange()
	}

	func upsertServiceRequest(_ serviceRequest: ServiceRequest) throws {
		guard let database = self.database else {
			Logger.background.error("Database not set")
			return
		}
		return try database.service.upsertServiceRequest(serviceRequest)
	}

	func upsertSource(_ source: MosquitoSource) throws {
		guard let database = self.database else {
			Logger.background.error("Database not set")
			return
		}
		return try database.service.upsertSource(source)
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

	func notesNeedingUploadAudio() throws -> [AudioNote] {
		guard let database = self.database else {
			Logger.background.error("Database not set")
			return []
		}

		return try database.service.audioThatNeedsUpload()
	}

	func onRegionChange(_ region: MKCoordinateRegion) {
		self.region = region
		self.calculateNotesToShow()
	}

	func saveAudioNote(_ recording: AudioNote) async throws {
		guard let database = self.database else {
			throw DatabaseError.notConnected
		}
		try database.service.insertAudioNote(recording)
	}

	func savePictureNote(_ picture: Photo, _ location: H3Cell?) throws {
		guard let database = self.database else {
			throw DatabaseError.notConnected
		}
		let uuid = UUID()
		let url = try! FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		).appendingPathComponent("\(uuid).photo")
		try picture.data.write(to: url)
		try database.service.insertPictureNote(
			uuid: uuid,
			location: location,
			created: Date.now
		)
		Logger.foreground.info("Saved picture \(uuid)")
	}

	func Load(database: DatabaseController, network: NetworkController) async throws {
		self.database = database
		self.network = network

		try await self.load()
		Logger.background.info("Notes load complete")
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
	func handleNoteUpdates(_ response: NotesResponse) async {
		/*
        do {
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
				try await network.uploadImage(image)
				try database.service.pictureUploaded(image)
				Logger.background.info(
					"Uploaded image \(image.uuidString)"
				)
			}
		}

	}

	/* private */
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
				Logger.background.info(
					"Should be uploading notes here, but I'm not yet."
				)
				/*let toUpload: [NidusNote] =
					note != nil
					? [note!] : try database.service.notesThatNeedUpload()
				// Upload notes first so that the back office gets them fastest
				for note in toUpload {
					try await network.uploadNote(note)
					note.uploaded = Date.now
					try database.service.noteUpdate(note)
					Logger.background.info(
						"Updated note \(note.id) to uploaded"
					)
				}*/
			}
			catch {
				doError(error)
			}
		}
	}
}

class NotesControllerPreview: NotesController {
	init(model: NotesModel = NotesModel()) {
		super.init()
		self.model = model
	}
}
