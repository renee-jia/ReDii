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
                        .background(Color(UIColor.systemGray6))
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
                    .keyboardType(.numberPad)
                    .padding(.horizontal)

                if let error = viewModel.pairingError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Button(action: {
                    Task {
                        await viewModel.pairWithCode()
                        if viewModel.isPaired {
                            appState = .home
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isPairing {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        }
                        Text("Connect")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(viewModel.enteredPairCode.isEmpty || viewModel.isPairing)
            }

            Spacer()

            Button("Skip for now") {
                viewModel.skipPairing()
                appState = .home
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 32)
        }
        .padding()
        .task {
            await viewModel.registerCurrentUser()
        }
    }
}

#Preview {
    PairingView(appState: .constant(.pairing))
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}
