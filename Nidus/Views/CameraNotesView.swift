//
//  CameraNotesView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/26/25.
//

import PhotosUI
import SwiftUI

struct PhotoAttachmentView: View {
	@State private var capturedImages: [UIImage] = []
	@State private var showingImagePicker = false
	@State private var showingCamera = false
	@State private var showingImageViewer = false
	@State private var selectedImageIndex = 0

	var body: some View {
		VStack {
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
		print("Number of images: \(capturedImages.count)")
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
		PhotoAttachmentView()
	}
}
