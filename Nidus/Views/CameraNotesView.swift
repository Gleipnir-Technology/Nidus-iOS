//
//  CameraNotesView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/26/25.
//

import PhotosUI
import SwiftUI

struct CameraNotesView: View {
	@State private var noteTitle = ""
	@State private var noteContent = ""
	@State private var capturedImages: [UIImage] = []
	@State private var showingImagePicker = false
	@State private var showingCamera = false
	@State private var showingImageViewer = false
	@State private var selectedImageIndex = 0

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Note Details")) {
					TextField("Title", text: $noteTitle)
					TextField("Content", text: $noteContent, axis: .vertical)
						.lineLimit(5, reservesSpace: true)
				}

				Section(header: Text("Photos")) {
					// Add Photo Buttons
					HStack {
						Button(action: {
							showingCamera = true
						}) {
							Label("Take Photo", systemImage: "camera")
								.foregroundColor(.blue)
						}

						Spacer()

						Button(action: {
							showingImagePicker = true
						}) {
							Label(
								"Choose Photo",
								systemImage: "photo.on.rectangle"
							)
							.foregroundColor(.blue)
						}
					}
					.padding(.vertical, 8)

					// Photo Thumbnails
					if !capturedImages.isEmpty {
						LazyVGrid(
							columns: [
								GridItem(.flexible()),
								GridItem(.flexible()),
								GridItem(.flexible()),
							],
							spacing: 10
						) {
							ForEach(
								Array(capturedImages.enumerated()),
								id: \.offset
							) { index, image in
								ZStack(alignment: .topTrailing) {
									Image(uiImage: image)
										.resizable()
										.aspectRatio(
											contentMode:
												.fill
										)
										.frame(
											width: 80,
											height: 80
										)
										.clipped()
										.cornerRadius(8)
										.onTapGesture {
											selectedImageIndex =
												index
											showingImageViewer =
												true
										}

									// Delete button
									Button(action: {
										capturedImages
											.remove(
												at:
													index
											)
									}) {
										Image(
											systemName:
												"xmark.circle.fill"
										)
										.foregroundColor(
											.red
										)
										.background(
											Color.white
										)
										.clipShape(Circle())
									}
									.offset(x: 5, y: -5)
								}
							}
						}
						.padding(.vertical, 8)
					}
				}

				Section {
					Button("Save Note") {
						saveNote()
					}
					.disabled(noteTitle.isEmpty)
				}
			}
			.navigationTitle("New Note")
			.navigationBarTitleDisplayMode(.inline)
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
			ImageViewer(images: capturedImages, selectedIndex: $selectedImageIndex)
		}
	}

	private func saveNote() {
		// Implement your save logic here
		print("Saving note: \(noteTitle)")
		print("Content: \(noteContent)")
		print("Number of images: \(capturedImages.count)")
	}
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
	let onImageCaptured: (UIImage) -> Void
	@Environment(\.dismiss) private var dismiss

	func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		picker.sourceType = .camera
		picker.allowsEditing = true
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
	{
		let parent: CameraView

		init(_ parent: CameraView) {
			self.parent = parent
		}

		func imagePickerController(
			_ picker: UIImagePickerController,
			didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
		) {
			if let image = info[.editedImage] as? UIImage ?? info[.originalImage]
				as? UIImage
			{
				parent.onImageCaptured(image)
			}
			parent.dismiss()
		}

		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			parent.dismiss()
		}
	}
}

// MARK: - Photo Picker
struct PhotoPicker: UIViewControllerRepresentable {
	let onImagesSelected: ([UIImage]) -> Void
	@Environment(\.dismiss) private var dismiss

	func makeUIViewController(context: Context) -> PHPickerViewController {
		var config = PHPickerConfiguration()
		config.filter = .images
		config.selectionLimit = 0  // 0 means no limit

		let picker = PHPickerViewController(configuration: config)
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, PHPickerViewControllerDelegate {
		let parent: PhotoPicker

		init(_ parent: PhotoPicker) {
			self.parent = parent
		}

		func picker(
			_ picker: PHPickerViewController,
			didFinishPicking results: [PHPickerResult]
		) {
			parent.dismiss()

			let group = DispatchGroup()
			var images: [UIImage] = []

			for result in results {
				group.enter()
				result.itemProvider.loadObject(ofClass: UIImage.self) {
					image,
					error in
					defer { group.leave() }
					if let image = image as? UIImage {
						DispatchQueue.main.async {
							images.append(image)
						}
					}
				}
			}

			group.notify(queue: .main) {
				self.parent.onImagesSelected(images)
			}
		}
	}
}

// MARK: - Image Viewer
struct ImageViewer: View {
	let images: [UIImage]
	@Binding var selectedIndex: Int
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationView {
			TabView(selection: $selectedIndex) {
				ForEach(Array(images.enumerated()), id: \.offset) { index, image in
					Image(uiImage: image)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.tag(index)
				}
			}
			.tabViewStyle(PageTabViewStyle())
			.navigationTitle("Photo \(selectedIndex + 1) of \(images.count)")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Done") {
						dismiss()
					}
				}
			}
		}
	}
}

// MARK: - Preview
struct CameraNotesView_Previews: PreviewProvider {
	static var previews: some View {
		CameraNotesView()
	}
}
