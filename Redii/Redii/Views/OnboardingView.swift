import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var diContainer: DIContainer
    @StateObject private var viewModel: OnboardingViewModel
    @Binding var appState: AppState
    
    init(appState: Binding<AppState>) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel())
        _appState = appState
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Redii")
                .font(.system(size: 48, weight: .light))
                .padding(.top, 80)
            
            Text("Two hearts. One center.")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            VStack(spacing: 16) {
                TextField("Nickname", text: $viewModel.nickname)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button(action: {
                    viewModel.createAccount()
                    if viewModel.createdUser != nil {
                        appState = .pairing
                    }
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(viewModel.nickname.isEmpty)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(appState: .constant(.onboarding))
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}

