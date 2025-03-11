//
//  TaskList.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI
struct TaskList: View {
    var body: some View {
        List(tasks) { task in TaskRow(task: task)
        }
    }
}

#Preview {
    TaskList()
}
