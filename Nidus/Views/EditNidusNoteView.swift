import AVFoundation
import CoreLocation
import OSLog
import Speech
import SwiftUI

struct EditNidusNoteView: View {
	@Environment(\.locale) var locale

	var locationDataManager: LocationDataManager
	@Binding var noteBuffer: ModelNoteBuffer
	var note: NidusNote?

	@State private var audioRecorder: AudioRecorder
	@State private var selectedImageIndex: Int = 0
	@State private var showingAudioPicker = false
	@State private var showingCamera = false
	@State private var showingImagePicker = false
	@State private var showingImageViewer = false
	@FocusState private var isTextFieldFocused: Bool
	private var useLocationManagerWhenAvailable: Bool

	init(
		audioRecorder: AudioRecorder = AudioRecorder(),
		locationDataManager: LocationDataManager,
		note: NidusNote? = nil,
		noteBuffer: Binding<ModelNoteBuffer>
	) {

		self._audioRecorder = .init(wrappedValue: audioRecorder)
		self._noteBuffer = .init(projectedValue: noteBuffer)
		self.locationDataManager = locationDataManager
		self.note = note
		self.useLocationManagerWhenAvailable = note == nil
	}

	var locationDescription: String {
		guard let location = noteBuffer.location else {
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
		noteBuffer.audioRecordings.append(recording)
	}

	var body: some View {
		ScrollViewReader { reader in
			Form {
				Section(header: Text("Location")) {
					VStack(alignment: .leading, spacing: 8) {
						if noteBuffer.location == nil {
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
								location: $noteBuffer.location
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
						recordings: $noteBuffer.audioRecordings
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
						capturedImages: $noteBuffer.capturedImages,
						selectedImageIndex:
							$selectedImageIndex,
						showingImageViewer:
							$showingImageViewer
					)
				}
				Section(header: Text("Text")) {
					TextField(
						"Additional text-only information",
						text: $noteBuffer.text
					)
					.cornerRadius(10)
					.frame(
						maxWidth: .infinity,
						alignment: .leading
					)
					.focused($isTextFieldFocused)
					.id("textField")
					.onChange(of: isTextFieldFocused) {
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
				$noteBuffer.audioRecordings
			) {
				_ in
			}
		}
		.sheet(isPresented: $showingCamera) {
			CameraView { image in
				noteBuffer.capturedImages.append(image)
			}
		}
		.sheet(isPresented: $showingImagePicker) {
			PhotoPicker { images in
				noteBuffer.capturedImages.append(contentsOf: images)
			}
		}
		.sheet(isPresented: $showingImageViewer) {
			ImageViewer(
				images: noteBuffer.capturedImages,
				onImageRemove: { at in noteBuffer.capturedImages.remove(at: at) },
				selectedIndex: $selectedImageIndex
			)
		}.onAppear {
			audioRecorder.onRecordingStop = onRecordingStop
			self.noteBuffer.Reset(note)
			locationDataManager.onLocationAcquired({ userLocation in
				if useLocationManagerWhenAvailable {
					self.noteBuffer.location = userLocation
				}
			})
		}
	}
}

// MARK: - Preview
struct AddNoteView_Previews: PreviewProvider {
	static var audioRecorder = AudioRecorderFake()
	@State static var noteBuffer = ModelNoteBuffer()
	static var previews: some View {
		EditNidusNoteView(
			audioRecorder: audioRecorder,
			locationDataManager: LocationDataManager(),
			note: nil,
			noteBuffer: $noteBuffer
		).previewDisplayName("user location")
		EditNidusNoteView(
			audioRecorder: audioRecorder,
			locationDataManager: LocationDataManagerFake(
				location: nil
			),
			note: NidusNote.forPreview(),
			noteBuffer: $noteBuffer
		).previewDisplayName("set location")
		EditNidusNoteView(
			audioRecorder: audioRecorder,
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			),
			note: NidusNote.forPreview(location: .visalia),
			noteBuffer: $noteBuffer
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
			note: NidusNote.forPreview(),
			noteBuffer: $noteBuffer
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
			),
			noteBuffer: $noteBuffer
		).previewDisplayName("multiple recording")
	}
}
