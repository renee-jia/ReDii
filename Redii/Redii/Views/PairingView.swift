import SwiftUI

struct PairingView: View {
    @EnvironmentObject var diContainer: DIContainer
    @StateObject private var viewModel: PairingViewModel
    @Binding var appState: AppState
    
    init(appState: Binding<AppState>) {
        _viewModel = StateObject(wrappedValue: PairingViewModel(
            cloudKitService: DIContainer().cloudKitService,
            currentUser: DIContainer().currentUser
        ))
        _appState = appState
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Pair Code")
                .font(.title)
                .padding(.bottom, 8)
            
            Text("Share your code or enter your partner's")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let code = diContainer.currentUser.pairCode {
                VStack(spacing: 16) {
                    Text(code)
                        .font(.system(size: 48, weight: .bold))
                        .monospaced()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Button("Share Code") {
                        viewModel.sharePairCode()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.vertical)
            
            VStack(spacing: 16) {
                TextField("Enter pair code", text: $viewModel.enteredPairCode)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await viewModel.pairWithCode()
                        if viewModel.isPaired {
                            appState = .home
                        }
                    }
                }) {
                    Text("Connect")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(viewModel.enteredPairCode.isEmpty)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PairingView(appState: .constant(.pairing))
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}

