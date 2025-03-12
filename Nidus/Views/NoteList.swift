//
//  NoteList.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI

struct NoteList: View {
	@Environment(ModelData.self) var modelData

	var body: some View {
		List(modelData.notes) { note in
			NavigationLink {
				NoteDetail(note: note)
			} label: {
				NoteRow(note: note)
			}
		}
	}
}

#Preview {
	NoteList().environment(ModelData())
}
