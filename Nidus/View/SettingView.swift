import OSLog
import SwiftUI

/*
 View for managing settings in the app.
 */
struct SettingView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var alertMessage = ""
	@State private var isShowingAlert = false
	@State private var password: String = ""
	@State private var showPassword: Bool = false
	@State private var url: String = "https://sync.nidus.cloud"
	@State private var username: String = ""

	var controller: RootController

	private var isFormValid: Bool {
		!username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			&& !password.isEmpty
	}

	private var lastSyncDisplay: String {
		guard let lastSync = controller.settings.store.lastSync else {
			return "Never"
		}
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDateString = formatter.localizedString(
			for: lastSync,
			relativeTo: Date.now
		)
		return "\(relativeDateString)\n(\(lastSync))"
	}
	private func loadCurrentSettings() {
		password = UserDefaults.standard.string(forKey: "password") ?? ""
		url = UserDefaults.standard.string(forKey: "sync-url") ?? "https://sync.nidus.cloud"
		username = UserDefaults.standard.string(forKey: "username") ?? ""
	}

	private func save() {
		let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

		controller.saveSettings(
			password: password,
			url: url,
			username: trimmedUsername
		)
		alertMessage = "Settings saved successfully!"
		isShowingAlert = true

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			dismiss()
		}
	}

	private func testLogin() {
		let loginURL = url + "/login"
		guard let url = URL(string: loginURL) else {
			alertMessage = "The sync server URL isn't valid"
			isShowingAlert = true
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue(
			"application/x-www-form-urlencoded",
			forHTTPHeaderField: "Content-Type"
		)
		let formData =
			"username=\(username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
		Logger.foreground.debug("Form data for login test: \(formData)")
		request.httpBody = formData.data(using: .utf8)
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					self.alertMessage = "Failed to login: \(error)"
					self.isShowingAlert = true
				}
				return
			}
			guard let httpResponse = response as? HTTPURLResponse else {
				self.alertMessage = "Failed to parse server response"
				self.isShowingAlert = true
				return
			}
			Logger.foreground.info("Login test status: \(httpResponse.statusCode)")
			if (200..<400) ~= httpResponse.statusCode {
				let success = [
					"Login looks good.",
					"Login works.",
					"Server says you're good to go.",
					"You're in!",
					"Works.",
				]
				self.alertMessage = success.randomElement()!
				self.isShowingAlert = true
			}
			else {
				self.alertMessage = "Login failed"
				self.isShowingAlert = true
				return
			}
		}.resume()
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
					Text("Last sync: \(lastSyncDisplay)")
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
					HStack {
						Button(action: { testLogin() }) {
							Label(
								"Test Login",
								systemImage:
									"person.fill.questionmark"
							)
						}
					}
				} header: {
					Text("Account Information")
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
	SettingView(controller: RootControllerPreview())
}
