//
//  TaskList.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI
struct TaskList: View {
    var body: some View {
        List {
            TaskRow(task: tasks[0])
            TaskRow(task: tasks[1])
        }
    }
}

#Preview {
    TaskList()
}
