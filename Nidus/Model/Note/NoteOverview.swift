import MapKit
import SwiftUI
import UIKit

struct NoteOverview: Identifiable {
	var color: Color
	var icon: Image
	var icons: [String]
	var id: UUID
	var location: H3Cell
	var time: Date
	var type: NoteType
}
