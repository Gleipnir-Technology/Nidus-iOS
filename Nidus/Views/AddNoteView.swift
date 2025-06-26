import AVFoundation
import CoreLocation
import Speech
import SwiftUI

struct AddNoteView: View {
	@State private var audioRecorder: AudioRecorder
	@State private var capturedImages: [UIImage] = []
	@Environment(\.locale) var locale
	@State var location: CLLocation?
	@State private var selectedImageIndex: Int = 0
	@State private var showingCamera = false
	@State private var showingImagePicker = false
	@State private var showingImageViewer = false

	private var useLocationManagerWhenAvailable: Bool
	var locationDataManager: LocationDataManager

	init(location: CLLocation?, locationDataManager: LocationDataManager) {
		self._audioRecorder = .init(wrappedValue: AudioRecorder())
		self._location = .init(wrappedValue: location)
		self.locationDataManager = locationDataManager
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

	var body: some View {
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
						LocationView(location: $location).frame(height: 300)
						Text("Where: \(locationDescription)")
					}
				}
			}

			Section(header: Text("Voice Notes")) {
				AudioRecorderView(audioRecorder: audioRecorder)
				Text("Transcription:")
				ScrollView {
					Text(audioRecorder.transcribedText)
						.padding()
						.frame(
							maxWidth: .infinity,
							alignment: .leading
						)
						.background(Color.blue.opacity(0.1))
						.cornerRadius(10)
				}
				.frame(maxHeight: 150)
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
	}

}

// MARK: - Preview
struct AddNoteView_Previews: PreviewProvider {
	static var previews: some View {
		AddNoteView(
			location: nil,
			locationDataManager: LocationDataManager()
		)
		AddNoteView(
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: LocationDataManagerFake(
				location: nil
			)
		)
		AddNoteView(
			location: CLLocation(latitude: 32.6514, longitude: -161.4333),
			locationDataManager: LocationDataManagerFake(
				location: CLLocation(latitude: 33.0, longitude: -161.5)
			)
		)
	}
}
