//
//  SettingView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/19/25.
//
import OSLog
import SwiftData
import SwiftUI

struct SettingView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext
	@State private var alertMessage = ""
	@State private var isShowingAlert = false
	@State private var password: String = ""
	@State private var showPassword: Bool = false
	@State private var url: String = "https://sync.nidus.cloud"
	@State private var username: String = ""
	var onSettingsUpdated: (() -> Void)

	private var currentSettings: Settings {
		if let result = try! modelContext.fetch(FetchDescriptor<Settings>()).first {
			return result
		}
		else {
			let instance = Settings(
				password: "foo",
				URL: "https://sync.nidus.cloud",
				username: "bar"
			)
			modelContext.insert(instance)
			return instance
		}
	}

	private var isFormValid: Bool {
		!username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			&& !password.isEmpty
	}

	private func deleteNotes() {
		do {
			try modelContext.delete(model: Note.self)
		}
		catch {
			Logger.foreground.error("Failed to delet notes: \(error)")
		}
	}

	private func loadCurrentSettings() {
		let settings = currentSettings
		password = settings.password
		username = settings.username
		url = settings.URL
		Logger.foreground.info("Loaded settings \(username)")
	}

	private func save() {
		let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

		let settings = currentSettings
		// Update existing settings
		settings.URL = url
		settings.username = trimmedUsername
		settings.password = password
		Logger.foreground.info("Updated settings")

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
		onSettingsUpdated()
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
				Section {
					HStack {
						Image(
							systemName: "trash"
						).foregroundColor(.red)
						Button(action: { deleteNotes() }) {
							Text("Delete all notes").foregroundColor(
								.red
							)
						}
					}
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

/*
 #Preview {
 SettingView().modelContainer(for: Settings.self, inMemory: true)
 }
*/
