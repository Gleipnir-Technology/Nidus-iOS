//
//  TaskList.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI
struct TaskList: View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        NavigationSplitView {
            List(modelData.tasks) { task in
                NavigationLink {
                    TaskDetail(task: task)
                } label: {
                    TaskRow(task: task)
                }
            }
            .navigationTitle("Notes")
        } detail: {
            Text("Select a task")
        }
    }
}

#Preview {
    TaskList().environment(ModelData())
}
