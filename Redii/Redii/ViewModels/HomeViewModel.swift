import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var daysTogether: Int = 0
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let momentRepository: MomentRepositoryProtocol
    private let appSettings: AppSettings
    private let anniversaryDate: Date?
    
    init(momentRepository: MomentRepositoryProtocol, appSettings: AppSettings, anniversaryDate: Date?) {
        self.momentRepository = momentRepository
        self.appSettings = appSettings
        self.anniversaryDate = anniversaryDate
    }
    
    func loadDaysTogether() {
        if let anniversary = anniversaryDate {
            let days = Calendar.current.dateComponents([.day], from: anniversary, to: Date()).day ?? 0
            daysTogether = max(0, days)
        }
    }
}

