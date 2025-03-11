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
        HStack {
            Text(String(task.id))
            Spacer()
            Text(task.title)
        }
        .padding()
    }
}

#Preview {
    TaskRow(task: tasks[0])
}
