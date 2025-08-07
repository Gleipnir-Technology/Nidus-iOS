import MapKit
import SwiftUI
import UIKit

struct NoteOverview: Hashable, Identifiable {
	var color: Color
	var icon: UIImage
	var icons: [String]
	var id: UUID = UUID()
	var location: H3Cell
	var time: Date
}
