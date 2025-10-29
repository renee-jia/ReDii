import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let senderID: UUID
    let timestamp: Date
    var reaction: String?
    
    static func create(text: String, senderID: UUID) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            text: text,
            senderID: senderID,
            timestamp: Date(),
            reaction: nil
        )
    }
}

