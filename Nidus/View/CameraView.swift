import SwiftUI

struct CameraView: View {
	let forPreview: Bool
	init(forPreview: Bool = false) {
		self.forPreview = forPreview
	}
	var body: some View {
		VStack {
			if forPreview {
				Spacer()
				Image(uiImage: UIImage(named: "camera-placeholder")!).resizable()
					.aspectRatio(contentMode: .fit).background(
						Color.cyan.opacity(0.4)
					)
			}
			Spacer()
			CameraControls()
		}
	}
}

struct CameraControls: View {
	var body: some View {
		HStack {
			Image(systemName: "photo").font(.system(size: 64, weight: .regular))
				.padding(20)
			Spacer()
			Image(systemName: "camera.aperture").font(
				.system(size: 82, weight: .regular)
			)
			Spacer()
			Image(systemName: "record.circle").font(.system(size: 64, weight: .regular))
				.padding(20)
		}
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		CameraView(forPreview: true)
	}
}
