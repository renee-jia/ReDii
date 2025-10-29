import Foundation

protocol ChatRepositoryProtocol {
    func fetchMessages() async throws -> [ChatMessage]
    func sendMessage(_ message: ChatMessage) async throws
    func addReaction(_ reaction: String, to messageID: UUID) async throws
}

class ChatRepository: ChatRepositoryProtocol {
    private let cloudKitService: CloudKitServiceProtocol
    private var messages: [ChatMessage] = []
    
    init(cloudKitService: CloudKitServiceProtocol) {
        self.cloudKitService = cloudKitService
    }
    
    func fetchMessages() async throws -> [ChatMessage] {
        return try await cloudKitService.fetchMessages()
    }
    
    func sendMessage(_ message: ChatMessage) async throws {
        messages.append(message)
        try await cloudKitService.sendMessage(message)
    }
    
    func addReaction(_ reaction: String, to messageID: UUID) async throws {
        guard let index = messages.firstIndex(where: { $0.id == messageID }) else { return }
        messages[index].reaction = reaction
        try await cloudKitService.updateMessageReaction(messageID: messageID, reaction: reaction)
    }
}

class InMemoryChatRepository: ChatRepositoryProtocol {
    private var messages: [ChatMessage] = []
    
    func fetchMessages() async throws -> [ChatMessage] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    func sendMessage(_ message: ChatMessage) async throws {
        messages.append(message)
    }
    
    func addReaction(_ reaction: String, to messageID: UUID) async throws {
        guard let index = messages.firstIndex(where: { $0.id == messageID }) else { return }
        messages[index].reaction = reaction
    }
}

