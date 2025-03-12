//
//  TaskDetail.swift
//  Nidus
//
//  Created by Eli Ribble on 3/12/25.
//

import SwiftUI

struct TaskDetail: View {
    var note: Note
    var body: some View {
        ScrollView {
            MapView(coordinate: note.locationCoordinate)
                .frame(height: 300)

            CircleImage(image: note.image)
                .offset(y: -130)
                .padding(.bottom, -130)

            VStack(alignment: .leading) {
                Text(note.title)
                    .font(.title)

                HStack {
                    Text(String(note.id))
                    Spacer()
                    Text(String(note.locationCoordinate.longitude))
                    Text(String(note.locationCoordinate.latitude))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                Text("About note")
                    .font(.title2)
            }
            .padding()
        }
        .navigationTitle(note.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TaskDetail(note: ModelData().notes[0])
}
