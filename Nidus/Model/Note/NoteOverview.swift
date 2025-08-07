import MapKit
import SwiftUI

struct NoteOverview: Hashable, Identifiable {
	var color: Color
	var icon: String
	var icons: [String]
	var id: UUID = UUID()
	var location: H3Cell
	var time: Date
}
