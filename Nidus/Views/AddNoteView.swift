import AVFoundation
import CoreLocation
import OSLog
import Speech
import SwiftUI

struct AddNoteView: View {
	@State private var audioRecorder: AudioRecorder
	@State private var capturedImages: [UIImage] = []
	@Environment(\.locale) var locale
	@State var location: CLLocation?
	var onAddNote: ((NidusNote) -> Void)
	@State private var selectedImageIndex: Int = 0
	@State private var showingCamera = false
	@State private var showingImagePicker = false
	@State private var showingImageViewer = false
	@State private var showLocationToast = false
	@State private var text = ""

	private var useLocationManagerWhenAvailable: Bool
	var locationDataManager: LocationDataManager

	init(
		audioRecorder: AudioRecorder = AudioRecorder(),
		location: CLLocation?,
		locationDataManager: LocationDataManager,
		onAddNote: @escaping ((NidusNote) -> Void) = { _ in }
	) {
		self._audioRecorder = .init(wrappedValue: audioRecorder)
		self._location = .init(wrappedValue: location)
		self.locationDataManager = locationDataManager
		self.onAddNote = onAddNote
		self.useLocationManagerWhenAvailable = (location == nil)
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

	func onSave() {
		if location == nil {
			showLocationToast = true
			return
		}
		let note = NidusNote(
			location: location!
		)
		onAddNote(note)
	}
	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Location")) {
					VStack(alignment: .leading, spacing: 8) {
						if location == nil {
							ProgressView().progressViewStyle(
								CircularProgressViewStyle()
							).frame(height: 300)
							Text("Getting a fix on your location...")
						}
						else {
							LocationView(location: $location).frame(
								height: 300
							)
							Text("Where: \(locationDescription)")
						}
					}
				}

				Section(header: Text("Voice Notes")) {
					AudioRecorderView(audioRecorder)
				}

				Section(header: Text("Photos")) {
					PhotoAttachmentView(
						selectedImageIndex: $selectedImageIndex,
						showingCamera: $showingCamera,
						showingImagePicker: $showingImagePicker,
						showingImageViewer: $showingImageViewer
					)
					ThumbnailListView(
						capturedImages: $capturedImages,
						selectedImageIndex: $selectedImageIndex,
						showingImageViewer: $showingImageViewer
					)
				}
				Section(header: Text("Text")) {

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
				locationDataManager.onLocationAcquired({ userLocation in
					if useLocationManagerWhenAvailable {
						self.location = userLocation
					}
				})
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Create note").toolbar {
				ToolbarItem {
					Button {
						onSave()
					} label: {
						Text("Save")
					}
				}
			}.toast(
				message: "Need a location first",
				isShowing: $showLocationToast,
				duration: Toast.short
			)
		}
	}
}

// MARK: - Preview
struct AddNoteView_Previews: PreviewProvider {
	static var previews: some View {
		AddNoteView(
			location: nil,
			locationDataManager: LocationDataManager()
		).previewDisplayName("user location")
		AddNoteView(
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: LocationDataManagerFake(
				location: nil
			)
		).previewDisplayName("set location")
		AddNoteView(
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			)
		).previewDisplayName("set location with user location")
		AddNoteView(
			audioRecorder: AudioRecorderFake(
				isRecording: true,
				recordingDuration: TimeInterval(integerLiteral: 98),
				transcribedText:
					"This is a bunch of stuff that I've just said that is all over this place. Let's assume that I've just filled this with tons and tons of words so that we can see what happens when we overflow the limits of the view."
			),
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			)
		).previewDisplayName("mid long recording")
	}
}
