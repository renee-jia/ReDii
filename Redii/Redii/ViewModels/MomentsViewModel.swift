import Foundation
import SwiftUI

@MainActor
class MomentsViewModel: ObservableObject {
    @Published var moments: [Moment] = []
    @Published var selectedFilter: Moment.MomentType? = nil
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let momentRepository: MomentRepositoryProtocol
    private let currentUserID: UUID
    
    init(momentRepository: MomentRepositoryProtocol, currentUserID: UUID) {
        self.momentRepository = momentRepository
        self.currentUserID = currentUserID
    }
    
    func loadMoments() async {
        isLoading = true
        error = nil
        
        do {
            moments = try await momentRepository.fetchMoments(type: selectedFilter)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func deleteMoment(_ moment: Moment) async {
        do {
            try await momentRepository.deleteMoment(id: moment.id)
            await loadMoments()
        } catch {
            self.error = error
        }
    }
}

