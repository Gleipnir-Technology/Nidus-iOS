//
//  NoteCategoryAdd.swift
//  Nidus
//
//  Created by Eli Ribble on 3/19/25.
//

import SwiftData
import SwiftUI

struct NoteCategoryAdd: View {
	@State private var name = ""

	var body: some View {
		Form {
			TextField("Name", text: $name)
		}.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Add Category")
			}
		}
	}
}

#Preview {
	ModelContainerPreview(ModelContainer.sample) {
		NoteCategoryAdd()
	}
}
