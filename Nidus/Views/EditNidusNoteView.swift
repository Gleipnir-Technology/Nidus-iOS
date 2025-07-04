import AVFoundation
import CoreLocation
import OSLog
import Speech
import SwiftUI

struct EditNidusNoteView: View {
	@State private var audioRecorder: AudioRecorder
	@State var audioRecordings: [AudioRecording] = []
	@State private var capturedImages: [UIImage]
	@Environment(\.locale) var locale
	@State var location: CLLocation?
	var note: NidusNote?
	var onSave: ((NidusNote, Bool) throws -> Void)
	@State private var selectedImageIndex: Int = 0
	@State private var showingAudioPicker = false
	@State private var showingCamera = false
	@State private var showingImagePicker = false
	@State private var showingImageViewer = false
	@State private var showLocationToast = false
	@State private var showSavedToast = false
	@State private var showSavedErrorToast = false
	@State private var text: String
	@FocusState private var isTextFieldFocused: Bool

	private var useLocationManagerWhenAvailable: Bool
	var locationDataManager: LocationDataManager

	init(
		audioRecorder: AudioRecorder = AudioRecorder(),
		locationDataManager: LocationDataManager,
		note: NidusNote? = nil,
		onSave: @escaping ((NidusNote, Bool) throws -> Void) = { _, _ in }
	) {

		self._audioRecorder = .init(wrappedValue: audioRecorder)
		self.locationDataManager = locationDataManager
		self.onSave = onSave
		self.note = note
		if note == nil {
			self.audioRecordings = []
			self.capturedImages = []
			self._location = .init(wrappedValue: nil)
			self.text = ""
			self.useLocationManagerWhenAvailable = true
		}
		else {
			self.audioRecordings = note!.audioRecordings
			let maybeImages = note!.images.map { $0.toUIImage() }
			self.capturedImages = maybeImages.compactMap { $0 }
			self._location = .init(
				wrappedValue: CLLocation(
					latitude: note!.location.latitude,
					longitude: note!.location.longitude
				)
			)
			self._text = .init(wrappedValue: note!.text)
			self.useLocationManagerWhenAvailable = false
		}
	}

	var locationDescription: String {
		guard let location = location else {
			return "current location"
		}
		guard let userLocation = locationDataManager.location else {
			return "...getting a fix"
		}
		let distance = Measurement(
			value: location.distance(from: userLocation),
			unit: UnitLength.meters
		)
		return distance.formatted(
			.measurement(width: .abbreviated, usage: .road).locale(locale)
		) + " away"
	}

	private func onRecordingStop(_ recording: AudioRecording) {
		audioRecordings.append(recording)
	}

	private func onSaveClick() {
		isTextFieldFocused = false
		if location == nil {
			showLocationToast = true
			return
		}
		var isNew = false
		var note = self.note
		if note == nil {
			note = NidusNote(
				audioRecordings: audioRecordings,
				images: capturedImages.map { NoteImage($0) },
				location: Location(location!),
				text: text
			)
			isNew = true
		}
		else {
			note!.audioRecordings = audioRecordings
			note!.images = capturedImages.map { NoteImage($0) }
			note!.location = Location(location!)
			note!.text = text
			isNew = false
		}
		do {
			try onSave(note!, isNew)
			showSavedToast = true
			if isNew {
				audioRecordings = []
				capturedImages = []
				text = ""
			}
		}
		catch {
			Logger.foreground.error("Failed to save note: \(error)")
			showSavedErrorToast = true
		}
	}

	var body: some View {
		ScrollViewReader { reader in
			Form {
				Section(header: Text("Location")) {
					VStack(alignment: .leading, spacing: 8) {
						if location == nil {
							ProgressView()
								.progressViewStyle(
									CircularProgressViewStyle()
								).frame(height: 300)
							Text(
								"Getting a fix on your location..."
							)
						}
						else {
							LocationView(
								location: $location
							).frame(
								height: 300
							)
							Text(
								"Where: \(locationDescription)"
							)
						}
					}
				}

				Section(header: Text("Voice Notes")) {
					AudioRecorderView(
						audioRecorder: audioRecorder,
						isShowingEditSheet:
							$showingAudioPicker,
						recordings: $audioRecordings
					)
				}

				Section(header: Text("Photos")) {
					PhotoAttachmentView(
						selectedImageIndex:
							$selectedImageIndex,
						showingCamera: $showingCamera,
						showingImagePicker:
							$showingImagePicker,
						showingImageViewer:
							$showingImageViewer
					)
					ThumbnailListView(
						capturedImages: $capturedImages,
						selectedImageIndex:
							$selectedImageIndex,
						showingImageViewer:
							$showingImageViewer
					)
				}
				Section(header: Text("Text")) {
					TextField(
						"Additional text-only information",
						text: $text
					)
					.cornerRadius(10)
					.frame(
						maxWidth: .infinity,
						alignment: .leading
					)
					.focused($isTextFieldFocused)
					.id("textField")
					.onChange(of: isTextFieldFocused) {
						Logger.foreground.info("ELI")
						reader.scrollTo(
							"textField",
							anchor: .bottom
						)
					}
				}
			}
		}
		.sheet(isPresented: $showingAudioPicker) {
			AudioPickerView(
				$audioRecordings
			) {
				_ in
			}
		}
		.sheet(isPresented: $showingCamera) {
			CameraView { image in
				capturedImages.append(image)
			}
		}
		.sheet(isPresented: $showingImagePicker) {
			PhotoPicker { images in
				capturedImages.append(contentsOf: images)
			}
		}
		.sheet(isPresented: $showingImageViewer) {
			ImageViewer(
				images: capturedImages,
				onImageRemove: { at in capturedImages.remove(at: at) },
				selectedIndex: $selectedImageIndex
			)
		}.onAppear {
			audioRecorder.onRecordingStop = onRecordingStop
			locationDataManager.onLocationAcquired({ userLocation in
				if useLocationManagerWhenAvailable {
					self.location = userLocation
				}
			})
		}.toast(
			message: "Need a location first",
			isShowing: $showLocationToast,
			duration: Toast.short
		).toast(
			message: "Note saved.",
			isShowing: $showSavedToast,
			duration: Toast.short
		).toast(
			message: "Failed to save note, tell a developer",
			isShowing: $showSavedErrorToast,
			duration: Toast.long
		)
	}
}

// MARK: - Preview
struct AddNoteView_Previews: PreviewProvider {
	static var audioRecorder = AudioRecorderFake()
	static var previews: some View {
		EditNidusNoteView(
			audioRecorder: audioRecorder,
			locationDataManager: LocationDataManager(),
			note: nil
		).previewDisplayName("user location")
		EditNidusNoteView(
			audioRecorder: audioRecorder,
			locationDataManager: LocationDataManagerFake(
				location: nil
			),
			note: NidusNote.forPreview()
		).previewDisplayName("set location")
		EditNidusNoteView(
			audioRecorder: audioRecorder,
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			),
			note: NidusNote.forPreview(location: .visalia)
		).previewDisplayName("set location with user location")
		EditNidusNoteView(
			audioRecorder: AudioRecorderFake(
				isRecording: true,
				recordingDuration: TimeInterval(integerLiteral: 98),
				transcribedText:
					"This is a bunch of stuff that I've just said that is all over this place. Let's assume that I've just filled this with tons and tons of words so that we can see what happens when we overflow the limits of the view."
			),
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			),
			note: NidusNote.forPreview()
		).previewDisplayName("mid long recording")
		EditNidusNoteView(
			audioRecorder: AudioRecorderFake(
				isRecording: false
			),
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			),
			note: NidusNote.forPreview(
				audioRecordings: [
					AudioRecording(
						created: Date.now.addingTimeInterval(-90),
						duration: 123,
						transcription: ""
					)
				]
			)
		).previewDisplayName("multiple recording")
	}
}
