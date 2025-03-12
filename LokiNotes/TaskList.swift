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
		List(modelData.tasks) { task in
			NavigationLink {
				TaskDetail(task: task)
			} label: {
				TaskRow(task: task)
			}
		}
	}
}

#Preview {
	TaskList().environment(ModelData())
}
