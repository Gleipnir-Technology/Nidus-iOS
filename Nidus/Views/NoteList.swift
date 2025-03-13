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
        NavigationSplitView {
            ZStack {
                if(modelData.notes.count == 0) {
                    Text("No notes yet")
                } else {
                    List(modelData.notes) { note in
                        NavigationLink {
                            NoteDetail(note: note)
                        } label: {
                            NoteRow(note: note)
                        }
                    }
                }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink {
                                NoteCreation()
                            } label: {
                                ButtonAddNote()
                            }
                        }
                    }
                    .navigationTitle("Notes")
                }
        } detail: {
            Text("Nidus")
        }
	}
}

#Preview {
	NoteList().environment(ModelData())
}
