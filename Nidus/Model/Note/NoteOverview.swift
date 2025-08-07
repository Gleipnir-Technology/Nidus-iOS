import MapKit
import SwiftUI

struct NoteOverview: Hashable, Identifiable {
	var id: UUID = UUID()

	var color: Color
	var icon: String
	var icons: [String]
	var location: H3Cell
	var time: Date
}
