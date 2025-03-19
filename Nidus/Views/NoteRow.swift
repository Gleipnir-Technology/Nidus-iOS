//
//  NoteRow.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI

struct NoteRow: View {
	var note: Note
	var body: some View {
		HStack {
			//note.image.resizable().frame(width: 50, height: 50)
			Text(note.content)
			Spacer()
		}
		.padding()
	}
}

#Preview("note 1") {
	Group {
		//NoteRow(note: ModelData().notes[0])
		//NoteRow(note: ModelData().notes[1])
		//NoteRow(note: note)
	}
}
