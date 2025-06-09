//
//  NidusModelPreview.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/4/25.
//
import SwiftUI

@Observable
class NidusModelPreview: NidusModel {
	init(
		backgroundNetworkProgress: Double = 0.0,
		backgroundNetworkState: BackgroundNetworkState = .idle
	) {
		super.init()
		self.backgroundNetworkProgress = backgroundNetworkProgress
		self.backgroundNetworkState = backgroundNetworkState
	}
}
