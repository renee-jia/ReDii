import SwiftUI

@main
struct RediiApp: App {
    @StateObject private var diContainer = DIContainer()
    @State private var appState: AppState = .onboarding
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    @State private var isUnlocked = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if appLockEnabled && !isUnlocked {
                    LockScreenView(isUnlocked: $isUnlocked)
                } else {
                    switch appState {
                    case .onboarding:
                        OnboardingView(appState: $appState)
                    case .pairing:
                        PairingView(appState: $appState)
                    case .home:
                        MainTabView()
                    }
                }
            }
            .environmentObject(diContainer)
            .onAppear {
                // Check if user already exists
                if let _ = UserDefaults.standard.data(forKey: "currentUser") {
                    if diContainer.currentUser.isPaired {
                        appState = .home
                    } else {
                        appState = .pairing
                    }
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase == .background && appLockEnabled {
                    isUnlocked = false
                }
            }
        }
    }
}

struct LockScreenView: View {
    @Binding var isUnlocked: Bool
    private let biometricService = BiometricAuthService.shared

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Redii is Locked")
                .font(.title2)

            Text("Authenticate to view your moments")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: authenticate) {
                HStack {
                    Image(systemName: biometricService.biometricIcon)
                    Text("Unlock with \(biometricService.biometricName)")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)

            Spacer()
        }
        .task {
            authenticate()
        }
    }

    private func authenticate() {
        Task {
            let success = await biometricService.authenticate()
            if success {
                isUnlocked = true
            }
        }
    }
}
