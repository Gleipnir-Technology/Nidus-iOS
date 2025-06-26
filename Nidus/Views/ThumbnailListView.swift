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

// MARK: - Preview
struct ThumbnailListView_Previews: PreviewProvider {
	@State static var capturedImages: [UIImage] = [
		UIImage(systemName: "photo")!,
		UIImage(systemName: "photo")!,
	]
	@State static var selectedImageIndex: Int = 0
	@State static var showingImageViewer: Bool = false
	static var previews: some View {
		VStack {
			ThumbnailListView(
				capturedImages: $capturedImages,
				selectedImageIndex: $selectedImageIndex,
				showingImageViewer: $showingImageViewer
			)
			Text("Selected index: \(selectedImageIndex)")
			Text("Showing image viewer: \(showingImageViewer)")
		}
	}
}
