import SwiftUI

struct PictureNoteDetail: View {
	var note: PictureNote
	var body: some View {
		VStack {
			Image(uiImage: note.uiImage)
		}
	}
}
