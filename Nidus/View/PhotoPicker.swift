//
//  PhotoPicker.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/26/25.
//

import PhotosUI
import SwiftUI

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
