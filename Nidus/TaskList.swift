//
//  TaskList.swift
//  Nidus
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI

struct TaskList: View {
	@Environment(ModelData.self) var modelData

	var body: some View {
		List(modelData.notes) { note in
			NavigationLink {
				TaskDetail(note: note)
			} label: {
				TaskRow(note: note)
			}
		}
	}
}

#Preview {
	TaskList().environment(ModelData())
}
