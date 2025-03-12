//
//  ContentView.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            ZStack {
                TaskList()
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink {
                            TaskCreation()
                        } label: {
                            ButtonAddTask()
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
