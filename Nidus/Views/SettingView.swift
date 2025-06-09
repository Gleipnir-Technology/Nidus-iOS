//
//  SettingView.swift
//  Nidus
//
//  Created by Eli Ribble on 3/19/25.
//
import OSLog
import SwiftUI

struct SettingView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var alertMessage = ""
	@State private var isShowingAlert = false
	@State private var password: String = ""
	@State private var showPassword: Bool = false
	@State private var url: String = "https://sync.nidus.cloud"
	@State private var username: String = ""
	var onSettingsUpdated: (() -> Void)

	private var isFormValid: Bool {
		!username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			&& !password.isEmpty
	}

	private func loadCurrentSettings() {
		password = UserDefaults.standard.string(forKey: "password") ?? ""
		url = UserDefaults.standard.string(forKey: "sync-url") ?? "https://sync.nidus.cloud"
		username = UserDefaults.standard.string(forKey: "username") ?? ""
	}

	private func save() {
		let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

		UserDefaults.standard.set(password, forKey: "password")
		UserDefaults.standard.set(url, forKey: "sync-url")
		UserDefaults.standard.set(trimmedUsername, forKey: "username")
		alertMessage = "Settings saved successfully!"
		isShowingAlert = true

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			dismiss()
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
	SettingView(onSettingsUpdated: {})
}
