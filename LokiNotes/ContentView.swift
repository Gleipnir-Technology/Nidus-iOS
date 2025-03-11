//
//  ContentView.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            TaskList()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ButtonAddTask()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
