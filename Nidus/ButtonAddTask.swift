//
//  ButtonAddTask.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/11/25.
//

import SwiftUI

struct ButtonAddTask: View {
	var body: some View {
		Label("Add Task", systemImage: "plus")
			.font(.system(.largeTitle))
			.labelStyle(.iconOnly)
			.frame(width: 65, height: 65)
			.foregroundColor(Color.white)
			.background(Color.yellow)
			.clipShape(Circle())
			.padding(.bottom, 7)
			.padding()
			.shadow(
				color: Color.black.opacity(0.3),
				radius: 3,
				x: 3,
				y: 3
			)
	}
}

#Preview {
	ButtonAddTask()
}
