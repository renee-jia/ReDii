import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var isCreatingAccount: Bool = false
    @Published var error: Error?
    @Published var createdUser: User?
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func createAccount() {
        guard !nickname.isEmpty else { return }
        
        isCreatingAccount = true
        
        let user = User.createNew(nickname: nickname)
        createdUser = user
        
        do {
            let data = try JSONEncoder().encode(user)
            userDefaults.set(data, forKey: "currentUser")
        } catch {
            self.error = error
        }
        
        isCreatingAccount = false
    }
}

