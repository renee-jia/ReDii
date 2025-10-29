import SwiftUI

@main
struct RediiApp: App {
    @StateObject private var diContainer = DIContainer()
    @State private var appState: AppState = .onboarding
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState {
                case .onboarding:
                    OnboardingView(appState: $appState)
                case .pairing:
                    PairingView(appState: $appState)
                case .home:
                    MainTabView()
                }
            }
            .environmentObject(diContainer)
        }
    }
}

