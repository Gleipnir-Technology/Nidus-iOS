import Foundation
import SwiftUI
import UIKit

enum NoteType {
	case audio
	case mosquitoSource
	case picture
}

protocol NoteProtocol: Identifiable<UUID>, Hashable {
	var category: NoteType { get }
	var cell: H3Cell { get }
	var id: UUID { get }
	var mapAnnotation: NoteMapAnnotation { get }
	var overview: NoteOverview { get }
	var created: Date { get }
}

func iconForNoteType(_ type: NoteType) -> Image {
	switch type {
	case .audio:
		return Image(systemName: "waveform")
	case .mosquitoSource:
		return Image("mosquito.sideview")
	case .picture:
		return Image(systemName: "photo")
	}
}
