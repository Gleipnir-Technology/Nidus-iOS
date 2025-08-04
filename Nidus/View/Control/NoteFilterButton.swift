import SwiftUI

struct NoteFilterButton: View {
	var body: some View {
		Button {
			// on press
		} label: {
			Image(systemName: "line.3.horizontal.decrease.circle").badge(4)
		}
	}
}
