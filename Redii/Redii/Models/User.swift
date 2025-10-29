import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    let nickname: String
    let pairCode: String?
    let anniversaryDate: Date?
    var isPaired: Bool
    let createdAt: Date
    
    static func createNew(nickname: String) -> User {
        User(
            id: UUID(),
            nickname: nickname,
            pairCode: generatePairCode(),
            anniversaryDate: nil,
            isPaired: false,
            createdAt: Date()
        )
    }
    
    private static func generatePairCode() -> String {
        String((100000...999999).randomElement() ?? 123456)
    }
}

