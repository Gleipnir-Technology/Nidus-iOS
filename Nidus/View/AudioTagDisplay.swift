import SwiftUI

struct AudioTagDisplay: View {
	let tags: [AudioTag]

	var body: some View {
		if tags.count == 0 {
			Spacer()
		}
		else {
			ForEach(tags, id: \.self) { tag in
				Text(tag.text).foregroundStyle(tag.color)
			}
		}
	}
}
