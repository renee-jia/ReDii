import Foundation
import SwiftUI

struct AIMessage: Identifiable, Codable {
    let id: UUID
    var content: String
    let timestamp: Date
    let role: MessageRole
    var attachments: [Attachment]?
    
    enum MessageRole: String, Codable {
        case user
        case assistant
    }
    
    enum AttachmentType: String, Codable {
        case image
        case voice
        case video
        case file
    }
    
    struct Attachment: Codable, Identifiable {
        let id: UUID
        let type: AttachmentType
        private let urlString: String
        var url: URL {
            URL(string: urlString) ?? URL(fileURLWithPath: "")
        }
        let name: String
        
        init(id: UUID = UUID(), type: AttachmentType, url: URL, name: String) {
            self.id = id
            self.type = type
            self.urlString = url.absoluteString
            self.name = name
        }
    }
    
    static func userMessage(content: String, attachments: [Attachment]? = nil) -> AIMessage {
        AIMessage(
            id: UUID(),
            content: content,
            timestamp: Date(),
            role: .user,
            attachments: attachments
        )
    }
    
    static func assistantMessage(content: String) -> AIMessage {
        AIMessage(
            id: UUID(),
            content: content,
            timestamp: Date(),
            role: .assistant
        )
    }
}
