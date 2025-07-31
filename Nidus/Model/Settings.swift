//
//  Settings.swift
//  Nidus Notes
//
//  Created by Eli Ribble on 5/27/25.
//

final class Settings {
	var password: String = ""
	var URL: String = ""
	var username: String = ""

	init(password: String, URL: String, username: String) {
		self.password = password
		self.URL = URL
		self.username = username
	}
}
