import Foundation
import SwiftUI

class DIContainer: ObservableObject {
    let persistenceController: PersistenceController
    let cloudKitService: CloudKitServiceProtocol
    let momentRepository: MomentRepositoryProtocol
    let chatRepository: ChatRepositoryProtocol
    let imageCacheService: ImageCacheService
    let voiceService: VoiceService
    let appSettings: AppSettings
    let currentUser: User
    let useInMemoryRepositories: Bool
    
    init(useInMemoryRepositories: Bool = false) {
        self.useInMemoryRepositories = useInMemoryRepositories
        
        persistenceController = PersistenceController.shared
        cloudKitService = CloudKitService()
        imageCacheService = ImageCacheService.shared
        voiceService = VoiceService()
        appSettings = AppSettings()
        
        momentRepository = useInMemoryRepositories ?
            InMemoryMomentRepository() :
            MomentRepository(persistenceController: persistenceController, cloudKitService: cloudKitService)
        
        chatRepository = useInMemoryRepositories ?
            InMemoryChatRepository() :
            ChatRepository(cloudKitService: cloudKitService)
        
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
        } else {
            self.currentUser = User.createNew(nickname: "User")
        }
    }
}

