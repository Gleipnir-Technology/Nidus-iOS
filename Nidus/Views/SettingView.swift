//
//  SettingView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/19/25.
//
import SwiftData
import SwiftUI

struct SettingView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext
	@State private var alertMessage = ""
	@State private var isShowingAlert = false
	@State private var password: String = ""
	@Query private var settings: [Settings]
	@State private var showPassword: Bool = false
	@State private var url: String = "https://sync.nidus.cloud"
	@State private var username: String = ""

	private var currentSettings: Settings? {
		settings.first
	}

	private var isFormValid: Bool {
		!username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			&& !password.isEmpty
	}

	private func loadCurrentSettings() {
		if let currentSettings = currentSettings {
			username = currentSettings.username
			password = currentSettings.password
		}
	}

	private func save() {
		let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

		if let existingSettings = currentSettings {
			// Update existing settings
			existingSettings.username = trimmedUsername
			existingSettings.password = password
		}
		else {
			// Create new settings
			let newSettings = Settings(
				password: password,
				URL: url,
				username: trimmedUsername
			)
			modelContext.insert(newSettings)
		}

		do {
			try modelContext.save()
			alertMessage = "Settings saved successfully!"
			isShowingAlert = true

			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				dismiss()
			}
		}
		catch {
			alertMessage = "Failed to save settings: \(error.localizedDescription)"
			isShowingAlert = true
		}
	}
	var body: some View {
		NavigationView {
			Form {
				Section {
					HStack {
						Image(
							systemName:
								"arrow.trianglehead.2.clockwise.rotate.90.circle"
						)
						.foregroundColor(.blue)
						.frame(width: 20)
						TextField("Sync URL", text: $url)
							.autocorrectionDisabled(
								true
							)
							#if !os(macOS)
								.textInputAutocapitalization(.never)
							#endif
					}
				} header: {
					Text("Sync Server")
				}
				Section {
					HStack {
						Image(systemName: "person.fill")
							.foregroundColor(.blue)
							.frame(width: 20)
						TextField("Enter username", text: $username)
							.textContentType(.username)
							.autocapitalization(.none)
							.disableAutocorrection(true)
					}
				} header: {
					Text("Account Information")
				}
				Section {
					HStack {
						Image(systemName: "lock.fill")
							.foregroundColor(.blue)
							.frame(width: 20)
						Group {
							if showPassword {
								TextField(
									"Enter password",
									text: $password
								).textContentType(.password)
									.autocapitalization(.none)
									.disableAutocorrection(true)
							}
							else {
								SecureField(
									"Enter password",
									text: $password
								)
							}
						}
						.textContentType(.newPassword)

						Button(action: { showPassword.toggle() }) {
							Image(
								systemName: showPassword
									? "eye.slash" : "eye"
							)
							.foregroundColor(.secondary)
						}
					}

				} header: {
					Text("Security")
				}
			}.navigationTitle("Settings")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button("Save") {
							save()
						}
						.fontWeight(.semibold)
						.disabled(!isFormValid)
					}
				}.onAppear {
					loadCurrentSettings()
				}.alert("Settings", isPresented: $isShowingAlert) {
					Button("OK") {}
				} message: {
					Text(alertMessage)
				}.textFieldStyle(.roundedBorder)
		}
	}
}

#Preview {
	SettingView().modelContainer(for: Settings.self, inMemory: true)
}
