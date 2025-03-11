//
//  TaskRow.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI
struct TaskRow: View {
    var task: Task
    var body: some View {
        HStack() {
            task.image.resizable().frame(width: 50, height: 50)
            Text(task.title)
            Spacer()
        }
        .padding()
    }
}

#Preview("task 1") {
    Group {
        TaskRow(task: tasks[0])
        TaskRow(task: tasks[1])
    }
}
