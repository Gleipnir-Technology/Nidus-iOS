//
//  ThumbnailListView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/26/25.
//

import PhotosUI
import SwiftUI

struct ThumbnailListView: View {
	@Binding var capturedImages: [UIImage]
	@Binding var selectedImageIndex: Int
	@Binding var showingImageViewer: Bool

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

				}
			}
			.padding(.vertical, 8)
		}

	}
}

// MARK: - Preview
struct ThumbnailListView_Previews: PreviewProvider {
	@State static var capturedImages: [UIImage] = [
		UIImage(systemName: "heart.text.clipboard")!,
		UIImage(systemName: "gear")!,
		UIImage(systemName: "cart")!,
		UIImage(systemName: "figure.walk.treadmill")!,
	]
	@State static var selectedImageIndex: Int = 0
	@State static var showingImageViewer: Bool = false
	static var previews: some View {
		ThumbnailListView(
			capturedImages: $capturedImages,
			selectedImageIndex: $selectedImageIndex,
			showingImageViewer: $showingImageViewer
		)
		.sheet(isPresented: $showingImageViewer) {
			ImageViewer(
				images: capturedImages,
				onImageRemove: { at in capturedImages.remove(at: at) },
				selectedIndex: $selectedImageIndex
			)
		}
	}
}
