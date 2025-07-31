//
//  CameraNotesView.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/26/25.
//

import PhotosUI
import SwiftUI

struct PhotoAttachmentView: View {
	@Binding var selectedImageIndex: Int
	@Binding var showingCamera: Bool
	@Binding var showingImagePicker: Bool
	@Binding var showingImageViewer: Bool

	var body: some View {
		HStack {
			// Add Photo Buttons
			Button(action: {
				showingCamera = true
			}) {
				Label("Take Photo", systemImage: "camera")
					.foregroundColor(.blue)
			}.buttonStyle(BorderlessButtonStyle())

			Spacer()

			Button(action: {
				showingImagePicker = true
			}) {
				Label(
					"Choose Photo",
					systemImage: "photo.on.rectangle"
				)
				.foregroundColor(.blue)
			}.buttonStyle(BorderlessButtonStyle())
		}
	}
}

// MARK: - Preview
struct CameraNotesView_Previews: PreviewProvider {
	@State static var selectedImageIndex: Int = 0
	@State static var showingCamera: Bool = false
	@State static var showingImagePicker: Bool = false
	@State static var showingImageViewer: Bool = false

	static var previews: some View {
		PhotoAttachmentView(
			selectedImageIndex: $selectedImageIndex,
			showingCamera: $showingCamera,
			showingImagePicker: $showingImagePicker,
			showingImageViewer: $showingImageViewer
		)
	}
}
