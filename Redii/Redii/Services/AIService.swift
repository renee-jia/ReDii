import Foundation

class AIService {
    static let shared = AIService()
    
    private let baseURL: String
    private let apiToken: String
    
    private init() {
        self.baseURL = "https://your-worker.workers.dev"
        self.apiToken = "your-api-token"
    }
    
    func polishMessage(_ text: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/ai/message-polish") else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["text": text]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.requestFailed
        }
        
        let result = try JSONDecoder().decode([String: String].self, from: data)
        return result["polishedText"] ?? text
    }
    
    func getDailyPrompt() async throws -> String {
        guard let url = URL(string: "\(baseURL)/ai/daily-prompt") else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.requestFailed
        }
        
        let result = try JSONDecoder().decode([String: String].self, from: data)
        return result["prompt"] ?? "What's on your mind today?"
    }
    
    func generateWeeklySummary(moments: [Moment]) async throws -> String {
        guard let url = URL(string: "\(baseURL)/ai/weekly-summary") else {
            throw AIServiceError.invalidURL
        }
        
        let momentsData = moments.map { moment in
            [
                "id": moment.id.uuidString,
                "type": moment.type.rawValue,
                "content": moment.content,
                "createdAt": ISO8601DateFormatter().string(from: moment.createdAt),
                "authorID": moment.authorID.uuidString
            ]
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["moments": momentsData]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.requestFailed
        }
        
        let result = try JSONDecoder().decode([String: String].self, from: data)
        return result["summary"] ?? "No summary available."
    }
}

enum AIServiceError: Error {
    case invalidURL
    case requestFailed
}

