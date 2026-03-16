import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var diContainer: DIContainer
    @AppStorage("themeColor") private var themeColor: ThemeColor = .pink
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    @State private var showingExportSheet = false
    @State private var exportFileURL: URL?
    @State private var showingClearAlert = false
    @State private var showingClearSuccess = false
    @State private var isExporting = false
    @State private var backendURL: String = UserDefaults.standard.string(forKey: "aiServiceBaseURL") ?? ""
    @State private var apiToken: String = UserDefaults.standard.string(forKey: "aiServiceAPIToken") ?? ""
    @State private var showingSavedAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    HStack {
                        Text("Nickname")
                        Spacer()
                        Text(diContainer.currentUser.nickname)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Pair Code")
                        Spacer()
                        Text(diContainer.currentUser.pairCode ?? "N/A")
                            .foregroundStyle(.secondary)
                            .monospaced()
                    }
                }

                Section("Appearance") {
                    Picker("Theme Color", selection: $themeColor) {
                        ForEach(ThemeColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                }

                Section("Security") {
                    Toggle(isOn: $appLockEnabled) {
                        HStack {
                            Image(systemName: diContainer.biometricAuthService.biometricIcon)
                            Text("App Lock (\(diContainer.biometricAuthService.biometricName))")
                        }
                    }
                    .onChange(of: appLockEnabled) { newValue in
                        if newValue {
                            Task {
                                let authenticated = await diContainer.biometricAuthService.authenticate()
                                if !authenticated {
                                    appLockEnabled = false
                                }
                            }
                        }
                    }
                }

                Section("AI Backend") {
                    TextField("Backend URL", text: $backendURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)

                    SecureField("API Token", text: $apiToken)

                    Button("Save Configuration") {
                        if !backendURL.isEmpty && !apiToken.isEmpty {
                            AIService.configure(baseURL: backendURL, apiToken: apiToken)
                            showingSavedAlert = true
                        }
                    }
                    .disabled(backendURL.isEmpty || apiToken.isEmpty)
                }

                Section("Data") {
                    Button(action: exportData) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Text("Export Data")
                            }
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .disabled(isExporting)

                    Button(role: .destructive) {
                        showingClearAlert = true
                    } label: {
                        Text("Clear All Data")
                    }
                }

                Section {
                    Text("Version 1.0.0")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .navigationTitle("Settings")
            .alert("Configuration Saved", isPresented: $showingSavedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your AI backend configuration has been saved.")
            }
            .alert("Clear All Data", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your moments, messages, and settings. This action cannot be undone.")
            }
            .alert("Data Cleared", isPresented: $showingClearSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("All local data has been cleared.")
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }

    private func exportData() {
        isExporting = true
        Task {
            do {
                let url = try await diContainer.dataExportService.exportMomentsAsJSON()
                exportFileURL = url
                showingExportSheet = true
            } catch {
                print("Export failed: \(error)")
            }
            isExporting = false
        }
    }

    private func clearAllData() {
        let context = diContainer.persistenceController.container.viewContext
        let fetchRequest = MomentEntity.fetchRequest()

        do {
            let entities = try context.fetch(fetchRequest)
            for entity in entities {
                context.delete(entity)
            }
            try context.save()
            showingClearSuccess = true
        } catch {
            print("Failed to clear data: \(error)")
        }

        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "aiServiceBaseURL")
        UserDefaults.standard.removeObject(forKey: "aiServiceAPIToken")
        backendURL = ""
        apiToken = ""
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}
