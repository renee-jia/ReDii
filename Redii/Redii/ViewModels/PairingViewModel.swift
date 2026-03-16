import Foundation
import SwiftUI

@MainActor
class PairingViewModel: ObservableObject {
    @Published var enteredPairCode: String = ""
    @Published var isPairing: Bool = false
    @Published var pairingError: String?
    @Published var isPaired: Bool = false
    @Published var partnerName: String?

    private let cloudKitService: CloudKitServiceProtocol
    private let currentUser: User

    init(cloudKitService: CloudKitServiceProtocol, currentUser: User) {
        self.cloudKitService = cloudKitService
        self.currentUser = currentUser
    }

    func registerCurrentUser() async {
        do {
            try await cloudKitService.registerUser(currentUser)
        } catch {
            // Registration is best-effort — pairing still works locally
            print("User registration failed: \(error)")
        }
    }

    func sharePairCode() {
        guard let code = currentUser.pairCode else { return }
        let items = [code]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    func pairWithCode() async {
        guard !enteredPairCode.isEmpty else { return }

        isPairing = true
        pairingError = nil

        do {
            let partner = try await cloudKitService.pairWithCode(enteredPairCode)
            if let partner = partner {
                partnerName = partner.nickname
                // Update current user as paired
                var updatedUser = currentUser
                updatedUser.isPaired = true
                if let data = try? JSONEncoder().encode(updatedUser) {
                    UserDefaults.standard.set(data, forKey: "currentUser")
                }
                isPaired = true

                // Subscribe to sync changes
                try? await cloudKitService.subscribeToChanges()
            } else {
                pairingError = "Could not find a partner with that code."
            }
        } catch let error as CloudKitError {
            pairingError = error.errorDescription
        } catch {
            pairingError = error.localizedDescription
        }

        isPairing = false
    }

    func skipPairing() {
        // Allow user to proceed without pairing
        var updatedUser = currentUser
        updatedUser.isPaired = true
        if let data = try? JSONEncoder().encode(updatedUser) {
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
        isPaired = true
    }
}
