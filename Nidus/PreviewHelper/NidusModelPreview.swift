//
//  NidusModelPreview.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/4/25.
//
import SwiftUI

@Observable
class NidusModelPreview: NidusModel {
	init(backgroundNetworkState: BackgroundNetworkState = .idle) {
		super.init()
		self.backgroundNetworkState = backgroundNetworkState
	}
}
