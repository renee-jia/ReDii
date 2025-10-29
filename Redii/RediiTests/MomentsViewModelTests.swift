import XCTest
@testable import Redii

@MainActor
final class MomentsViewModelTests: XCTestCase {
    var viewModel: MomentsViewModel!
    var repository: InMemoryMomentRepository!
    
    override func setUp() {
        repository = InMemoryMomentRepository()
        viewModel = MomentsViewModel(
            momentRepository: repository,
            currentUserID: UUID()
        )
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.moments.isEmpty)
        XCTAssertNil(viewModel.selectedFilter)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadMoments() async {
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
        
        try? await repository.createMoment(moment)
        
        await viewModel.loadMoments()
        
        XCTAssertEqual(viewModel.moments.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testDeleteMoment() async {
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
        
        try? await repository.createMoment(moment)
        await viewModel.loadMoments()
        
        await viewModel.deleteMoment(moment)
        
        XCTAssertTrue(viewModel.moments.isEmpty)
    }
}

