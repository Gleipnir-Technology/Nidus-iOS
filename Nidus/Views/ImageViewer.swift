//
//  ImageViewer.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/26/25.
//

import PhotosUI
import SwiftUI

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
