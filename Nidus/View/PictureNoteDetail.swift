import SwiftUI

struct PictureNoteDetail: View {
	var note: PictureNote
	var body: some View {
		VStack {
			if note.location != 0 {
				MapCellView(
					cell: note.location
				).frame(height: 300)
			}
			Image(uiImage: note.uiImage).resizable().aspectRatio(contentMode: .fit)
		}
	}
}

#Preview {
	PictureNoteDetail(
		note: PictureNote.forPreview(location: 0x8f4_8eba_314c_0ac5)
	)
}
