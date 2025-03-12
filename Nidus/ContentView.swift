//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            ZStack {
                NoteList()
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
            }
            .navigationTitle("Notes")
        } detail: {
            Text("Nidus")
        }
    }
}

#Preview {
    ContentView().environment(ModelData())
}
