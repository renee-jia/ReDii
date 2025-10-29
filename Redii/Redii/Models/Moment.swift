import Foundation

struct Moment: Identifiable, Codable, Equatable {
    let id: UUID
    let type: MomentType
    let content: String
    let createdAt: Date
    let authorID: UUID
    var photoURL: URL?
    var voiceURL: URL?
    var mood: Mood?
    
    enum MomentType: String, Codable, CaseIterable {
        case note
        case photo
        case mood
        case voice
    }
    
    struct Mood: Codable, Equatable {
        let emoji: String
        let label: String
    }
}

