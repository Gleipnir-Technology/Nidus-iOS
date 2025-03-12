//
//  TaskDetail.swift
//  LokiNotes
//
//  Created by Eli Ribble on 3/12/25.
//

import SwiftUI
struct TaskDetail: View {
    var task: Task
    var body: some View {
        ScrollView {
            MapView(coordinate: task.locationCoordinate)
                .frame(height: 300)

            CircleImage(image: task.image)
                .offset(y: -130)
                .padding(.bottom, -130)

            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.title)

                HStack {
                    Text(String(task.id))
                    Spacer()
                    Text(String(task.locationCoordinate.longitude))
                    Text(String(task.locationCoordinate.latitude))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                Text("About task")
                    .font(.title2)
            }
            .padding()
        }
        .navigationTitle(task.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TaskDetail(task: tasks[0])
}
