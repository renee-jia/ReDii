import Foundation

enum AppState: Equatable {
    case onboarding
    case pairing
    case home
}

struct AppSettings: Codable {
    var themeColor: ThemeColor
    var appLockEnabled: Bool
    var anniversaryDate: Date?
    
    init() {
        self.themeColor = .pink
        self.appLockEnabled = false
        self.anniversaryDate = nil
    }
}

enum ThemeColor: String, Codable, CaseIterable {
    case pink = "Pink"
    case purple = "Purple"
    case blue = "Blue"
    
    var colorName: String {
        rawValue.lowercased()
    }
}

