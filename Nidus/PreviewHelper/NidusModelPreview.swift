//
//  NidusModelPreview.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/4/25.
//
import SwiftUI

@Observable
class NidusModelPreview: ModelNidus {
	var notesToShowOverride: [AnyNote]?

	init(
		backgroundNetworkProgress: Double = 0.0,
		backgroundNetworkState: BackgroundNetworkState = .idle,
		errorMessage: String? = nil,
		notes: [AnyNote] = [],
		notesToShow: [AnyNote]? = nil
	) {
		super.init()
		self.backgroundNetworkProgress = backgroundNetworkProgress
		self.backgroundNetworkState = backgroundNetworkState
		self.errorMessage = errorMessage
		var noteMap: [UUID: AnyNote] = [:]
		for n in notes {
			noteMap[n.id] = n
		}
		self.notes = noteMap
		self.notesToShowOverride = notesToShow
	}

	override var notesToShow: [AnyNote] {
		if notesToShowOverride != nil {
			return notesToShowOverride!
		}
		return Array(notes.values)
	}
}
