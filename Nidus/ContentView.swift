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

	var body: some View {
		NoteListView()
	}
}

#Preview("Loading") {
	ContentView().modelContainer(try! ModelContainer.sample())
}
