import Foundation
import SwiftUI

@MainActor
class PairingViewModel: ObservableObject {
    @Published var enteredPairCode: String = ""
    @Published var isPairing: Bool = false
    @Published var pairingError: Error?
    @Published var isPaired: Bool = false
    
    private let cloudKitService: CloudKitServiceProtocol
    private let currentUser: User
    
    init(cloudKitService: CloudKitServiceProtocol, currentUser: User) {
        self.cloudKitService = cloudKitService
        self.currentUser = currentUser
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
        isPairing = true
        pairingError = nil
        
        do {
            try await cloudKitService.pairWithCode(enteredPairCode)
            isPaired = true
        } catch {
            pairingError = error
        }
        
        isPairing = false
    }
}

