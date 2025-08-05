import SwiftUI

struct CameraView: View {
	let forPreview: Bool
	init(forPreview: Bool = false) {
		self.forPreview = forPreview
	}
	var body: some View {
		VStack {
			if forPreview {
				Image(uiImage: UIImage(named: "camera-placeholder")!)
			}
			ProgressView()
			Spacer()
			CameraControls()
		}
	}
}

struct CameraControls: View {
	var body: some View {
		HStack {
			Image(systemName: "photo")
			Circle().foregroundStyle(.blue)
			Image(systemName: "record.circle")
		}
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		CameraView(forPreview: true)
	}
}
