import Foundation
import SwiftUI

class DIContainer: ObservableObject {
    let persistenceController: PersistenceController
    let cloudKitService: CloudKitServiceProtocol
    let momentRepository: MomentRepositoryProtocol
    let chatRepository: ChatRepositoryProtocol
    let imageCacheService: ImageCacheService
    let voiceService: VoiceService
    let biometricAuthService: BiometricAuthService
    let dataExportService: DataExportService
    let appSettings: AppSettings
    let currentUser: User
    let useInMemoryRepositories: Bool

    init(useInMemoryRepositories: Bool = false) {
        self.useInMemoryRepositories = useInMemoryRepositories

        persistenceController = useInMemoryRepositories
            ? PersistenceController(inMemory: true)
            : PersistenceController.shared
        cloudKitService = CloudKitService()
        imageCacheService = ImageCacheService.shared
        voiceService = VoiceService()
        biometricAuthService = BiometricAuthService.shared
        appSettings = AppSettings()

        let momentRepo: MomentRepositoryProtocol = useInMemoryRepositories
            ? InMemoryMomentRepository()
            : MomentRepository(persistenceController: persistenceController, cloudKitService: cloudKitService)
        momentRepository = momentRepo

        chatRepository = useInMemoryRepositories
            ? InMemoryChatRepository()
            : ChatRepository(cloudKitService: cloudKitService)

        dataExportService = DataExportService(momentRepository: momentRepo)

        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
        } else {
            self.currentUser = User.createNew(nickname: "User")
        }
    }
}
