import SwiftUI

protocol NoteOverview {
	var color: Color { get }
	var icon: String { get }
	var icons: [String] { get }
	var time: Date { get }
}

class NoteOverviewFlat: Identifiable, NoteOverview {
	var color: Color
	var icon: String
	var icons: [String]
	var time: Date
	/*var image: CGImage { get {

    } }*/
	init(color: Color, icon: String, icons: [String], time: Date) {
		self.color = color
		self.icon = icon
		self.icons = icons
		self.time = time
	}
}
