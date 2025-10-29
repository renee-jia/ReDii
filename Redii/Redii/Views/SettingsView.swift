import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var diContainer: DIContainer
    @AppStorage("themeColor") private var themeColor: ThemeColor = .pink
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    
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
                    Toggle("App Lock", isOn: $appLockEnabled)
                }
                
                Section("Data") {
                    Button(action: {
                        // Export functionality
                    }) {
                        HStack {
                            Text("Export Data")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    
                    Button(role: .destructive) {
                        // Clear data
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
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}

