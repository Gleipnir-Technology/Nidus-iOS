//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var context
	@State var locationDataManager: LocationDataManager = LocationDataManager()
	@State var currentValue: Float = 0.0

	var body: some View {
		VStack {
			NoteListView(userLocation: locationDataManager.location)
			Spacer()
			Slider(value: $currentValue)
			HStack {
				Spacer()
				Image(systemName: "clock").resizable().scaledToFill().frame(
					width: 50,
					height: 50
				).foregroundColor(.blue).onTapGesture {
				}
				Spacer()
				Image(systemName: "map").resizable().scaledToFill().frame(
					width: 50,
					height: 50
				).foregroundColor(.blue).onTapGesture {
				}
				Spacer()
				Image(systemName: "checklist").resizable().scaledToFill().frame(
					width: 50,
					height: 50
				).foregroundColor(.blue).onTapGesture {
				}
				Spacer()
				Image(systemName: "plus.circle").resizable().scaledToFill().frame(
					width: 50,
					height: 50
				).foregroundColor(.blue).onTapGesture {
				}
				Spacer()
			}
		}
	}
}

#Preview("Loading") {
	ContentView().modelContainer(try! ModelContainer.sample())
}
