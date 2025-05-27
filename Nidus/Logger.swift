//
//  Logger.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/27/25.
//

import OSLog

extension Logger {
	private static var subsystem = Bundle.main.bundleIdentifier!
	static let background = Logger(subsystem: subsystem, category: "background")
	static let foreground = Logger(subsystem: subsystem, category: "foreground")
}
