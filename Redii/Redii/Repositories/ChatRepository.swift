import Foundation

protocol ChatRepositoryProtocol {
    func fetchMessages() async throws -> [ChatMessage]
    func sendMessage(_ message: ChatMessage) async throws
    func addReaction(_ reaction: String, to messageID: UUID) async throws
}

class ChatRepository: ChatRepositoryProtocol {
    private let cloudKitService: CloudKitServiceProtocol
    private var localMessages: [ChatMessage] = []

    init(cloudKitService: CloudKitServiceProtocol) {
        self.cloudKitService = cloudKitService
    }

    func fetchMessages() async throws -> [ChatMessage] {
        do {
            let cloudMessages = try await cloudKitService.fetchMessages()
            // Merge cloud messages with local cache
            var merged = localMessages
            for msg in cloudMessages where !merged.contains(where: { $0.id == msg.id }) {
                merged.append(msg)
            }
            merged.sort { $0.timestamp < $1.timestamp }
            localMessages = merged
            return merged
        } catch {
            // Return local cache if CloudKit fails
            return localMessages.sorted { $0.timestamp < $1.timestamp }
        }
    }

    func sendMessage(_ message: ChatMessage) async throws {
        localMessages.append(message)

        // Sync to CloudKit in background
        Task {
            try? await cloudKitService.sendMessage(message)
        }
    }

    func addReaction(_ reaction: String, to messageID: UUID) async throws {
        if let index = localMessages.firstIndex(where: { $0.id == messageID }) {
            localMessages[index].reaction = reaction
        }

        Task {
            try? await cloudKitService.updateMessageReaction(messageID: messageID, reaction: reaction)
        }
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
