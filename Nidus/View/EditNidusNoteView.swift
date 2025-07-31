import AVFoundation
import CoreLocation
import OSLog
import Speech
import SwiftUI

struct EditNidusNoteView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.locale) var locale

	var locationDataManager: LocationDataManager
	var isTextFieldFocused: FocusState<Bool>.Binding
	@Binding var noteBuffer: ModelNoteBuffer
	var note: NidusNote?
	var onDeleteNote: (() -> Void)
	var onResetChanges: (() -> Void)

	@State private var selectedImageIndex: Int = 0
	@State private var showingAudioPicker = false
	@State private var showingCamera = false
	@State private var showingImagePicker = false
	@State private var showingImageViewer = false
	private var useLocationManagerWhenAvailable: Bool

	init(
		isTextFieldFocused: FocusState<Bool>.Binding,
		locationDataManager: LocationDataManager,
		note: NidusNote? = nil,
		noteBuffer: Binding<ModelNoteBuffer>,
		onDeleteNote: @escaping () -> Void,
		onResetChanges: @escaping () -> Void
	) {

		self.isTextFieldFocused = isTextFieldFocused
		self._noteBuffer = .init(projectedValue: noteBuffer)
		self.locationDataManager = locationDataManager
		self.note = note
		self.onDeleteNote = onDeleteNote
		self.onResetChanges = onResetChanges
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

	private func deleteNote() {
		onDeleteNote()
		dismiss()
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
				Section(header: Text("Time")) {
					if note != nil {
						HStack {
							Text("Created:")
							Text(note!.created, style: .date)
								.foregroundStyle(.secondary)
						}
					}
					HStack {
						DatePicker(
							selection: $noteBuffer.dueDate,
							displayedComponents: .date,
							label: { Text("Due Date") }
						)
					}
				}
				Section(header: Text("Text")) {
					TextField(
						"Additional text-only information",
						text: $noteBuffer.text
					)
					.cornerRadius(10)
					.frame(
						maxWidth: .infinity,
						minHeight: 80,
						alignment: .leading
					)
					.focused(isTextFieldFocused)
					.id("textField")
					.onChange(of: isTextFieldFocused.wrappedValue) {
						reader.scrollTo("textField", anchor: .bottom)
					}

				}
				Section(header: Text("Actions")) {
					Button(action: onResetChanges) {
						Label(
							"Reset Changes",
							systemImage: "arrow.clockwise.circle.fill"
						)
					}
					if note != nil {
						Button(action: deleteNote) {
							Label("Delete Note", systemImage: "trash")
						}.foregroundStyle(.red)
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
	@FocusState static var isTextFieldFocused: Bool
	@State static var noteBuffer = ModelNoteBuffer()
	static func onResetChanges() {}
	static func onDeleteNote() {}
	static var previews: some View {
		EditNidusNoteView(
			isTextFieldFocused: $isTextFieldFocused,
			locationDataManager: LocationDataManager(),
			note: nil,
			noteBuffer: $noteBuffer,
			onDeleteNote: onDeleteNote,
			onResetChanges: onResetChanges
		).previewDisplayName("user location")
		EditNidusNoteView(
			isTextFieldFocused: $isTextFieldFocused,
			locationDataManager: LocationDataManagerFake(
				location: nil
			),
			note: NidusNote.forPreview(),
			noteBuffer: $noteBuffer,
			onDeleteNote: onDeleteNote,
			onResetChanges: onResetChanges
		).previewDisplayName("set location")
		EditNidusNoteView(
			isTextFieldFocused: $isTextFieldFocused,
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			),
			note: NidusNote.forPreview(location: .visalia),
			noteBuffer: $noteBuffer,
			onDeleteNote: onDeleteNote,
			onResetChanges: onResetChanges
		).previewDisplayName("set location with user location")
		EditNidusNoteView(
			isTextFieldFocused: $isTextFieldFocused,
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			),
			note: NidusNote.forPreview(),
			noteBuffer: $noteBuffer,
			onDeleteNote: onDeleteNote,
			onResetChanges: onResetChanges
		).previewDisplayName("mid long recording")
		EditNidusNoteView(
			isTextFieldFocused: $isTextFieldFocused,
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
			noteBuffer: $noteBuffer,
			onDeleteNote: onDeleteNote,
			onResetChanges: onResetChanges
		).previewDisplayName("multiple recording")
	}
}
