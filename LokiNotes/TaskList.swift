//
//  TaskList.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI
struct TaskList: View {
    var body: some View {
        NavigationSplitView {
            List(tasks) { task in
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
    TaskList()
}
