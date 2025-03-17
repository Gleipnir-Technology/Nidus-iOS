//
//  CircleImage.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//

import SwiftUI

struct CircleImage: View {
	var image: Image
	var body: some View {
		image.clipShape(Circle())
			.overlay {
				Circle().stroke(.white, lineWidth: 4)
			}
			.shadow(radius: 7)
	}
}

#Preview {
	CircleImage(image: Image("NoteTypeIconInfo"))
}
