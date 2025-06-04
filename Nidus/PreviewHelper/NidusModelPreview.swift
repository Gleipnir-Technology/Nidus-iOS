//
//  NidusModelPreview.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 6/4/25.
//
import SwiftUI

@Observable
class NidusModelPreview: NidusModel {
	init(isDownloading: Bool = false) {
		super.init()
		self.isDownloading = isDownloading
	}
}
