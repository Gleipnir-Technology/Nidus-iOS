//
//  NavigationContext.swift
//  Nidus
//
//  Created by Eli Ribble on 3/17/25.
//

import SwiftUI

@Observable
class NavigationContext {
	var selectedNote: Note?

	init(selectedNote: Note? = nil) {
		self.selectedNote = selectedNote
	}
}
