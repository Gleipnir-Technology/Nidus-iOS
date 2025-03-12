//
//  TaskRow.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI
struct TaskRow: View {
    var note: Note
    var body: some View {
        HStack() {
            note.image.resizable().frame(width: 50, height: 50)
            Text(note.title)
            Spacer()
        }
        .padding()
    }
}

#Preview("note 1") {
    Group {
        TaskRow(note: ModelData().notes[0])
        TaskRow(note: ModelData().notes[1])
    }
}
