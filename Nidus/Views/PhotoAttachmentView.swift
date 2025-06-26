//
//  CameraNotesView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/26/25.
//

import PhotosUI
import SwiftUI

struct ThumbnailListView: View {
	@Binding var capturedImages: [UIImage]
	@Binding var selectedImageIndex: Int
	@State private var showingImageViewer = false

	var body: some View {
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
}
struct PhotoAttachmentView: View {
	@Binding var capturedImages: [UIImage]
	@Binding var selectedImageIndex: Int
	@Binding var showingCamera: Bool
	@Binding var showingImagePicker: Bool
	@Binding var showingImageViewer: Bool

	var body: some View {
		VStack {
			// Add Photo Buttons
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

			ThumbnailListView(
				capturedImages: $capturedImages,
				selectedImageIndex: $selectedImageIndex
			)
		}
	}

	private func saveNote() {
		// Implement your save logic here
		print("Number of images: \(capturedImages.count)")
	}
}

// MARK: - Preview
struct CameraNotesView_Previews: PreviewProvider {
	@State static var capturedImages: [UIImage] = []
	@State static var selectedImageIndex: Int = 0
	@State static var showingCamera: Bool = false
	@State static var showingImagePicker: Bool = false
	@State static var showingImageViewer: Bool = false

	static var previews: some View {
		PhotoAttachmentView(
			capturedImages: $capturedImages,
			selectedImageIndex: $selectedImageIndex,
			showingCamera: $showingCamera,
			showingImagePicker: $showingImagePicker,
			showingImageViewer: $showingImageViewer
		)
	}
}
