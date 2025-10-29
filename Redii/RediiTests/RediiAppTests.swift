import XCTest
@testable import Redii

final class RediiAppTests: XCTestCase {
    func testUserCreation() {
        let user = User.createNew(nickname: "Test User")
        XCTAssertEqual(user.nickname, "Test User")
        XCTAssertNotNil(user.pairCode)
        XCTAssertFalse(user.isPaired)
    }
    
    func testMomentCreation() {
        let user = User.createNew(nickname: "Test")
        let moment = Moment(
            id: UUID(),
            type: .note,
            content: "Test moment",
            createdAt: Date(),
            authorID: user.id,
            photoURL: nil,
            voiceURL: nil,
            mood: nil
        )
        XCTAssertEqual(moment.content, "Test moment")
        XCTAssertEqual(moment.type, .note)
    }
    
    func testChatMessageCreation() {
        let user = User.createNew(nickname: "Test")
        let message = ChatMessage.create(text: "Hello", senderID: user.id)
        XCTAssertEqual(message.text, "Hello")
        XCTAssertEqual(message.senderID, user.id)
    }
}

