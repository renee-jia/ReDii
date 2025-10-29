import XCTest
@testable import Redii

@MainActor
final class MomentRepositoryTests: XCTestCase {
    var repository: InMemoryMomentRepository!
    
    override func setUp() {
        repository = InMemoryMomentRepository()
    }
    
    func testFetchMoments() async throws {
        let moments = try await repository.fetchMoments()
        XCTAssertTrue(moments.isEmpty)
    }
    
    func testCreateMoment() async throws {
        let moment = Moment(
            id: UUID(),
            type: .note,
            content: "Test",
            createdAt: Date(),
            authorID: UUID(),
            photoURL: nil,
            voiceURL: nil,
            mood: nil
        )
        
        try await repository.createMoment(moment)
        let moments = try await repository.fetchMoments()
        
        XCTAssertEqual(moments.count, 1)
        XCTAssertEqual(moments.first?.content, "Test")
    }
    
    func testDeleteMoment() async throws {
        let moment = Moment(
            id: UUID(),
            type: .note,
            content: "Test",
            createdAt: Date(),
            authorID: UUID(),
            photoURL: nil,
            voiceURL: nil,
            mood: nil
        )
        
        try await repository.createMoment(moment)
        try await repository.deleteMoment(id: moment.id)
        
        let moments = try await repository.fetchMoments()
        XCTAssertTrue(moments.isEmpty)
    }
    
    func testFilterMoments() async throws {
        let note = Moment(
            id: UUID(),
            type: .note,
            content: "Note",
            createdAt: Date(),
            authorID: UUID(),
            photoURL: nil,
            voiceURL: nil,
            mood: nil
        )
        
        let photo = Moment(
            id: UUID(),
            type: .photo,
            content: "Photo",
            createdAt: Date(),
            authorID: UUID(),
            photoURL: nil,
            voiceURL: nil,
            mood: nil
        )
        
        try await repository.createMoment(note)
        try await repository.createMoment(photo)
        
        let photos = try await repository.fetchMoments(type: .photo)
        XCTAssertEqual(photos.count, 1)
        XCTAssertEqual(photos.first?.type, .photo)
    }
}

