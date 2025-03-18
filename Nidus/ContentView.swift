//
//  ContentView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/6/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
	@State private var navigationContext = NavigationContext()

	var body: some View {
		NoteListView()
			.environment(navigationContext)
	}
}

#Preview("Loading") {
	ContentView().modelContainer(try! ModelContainer.sample())
}
