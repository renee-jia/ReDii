import Foundation

class AIService {
    static let shared = AIService()

    private var baseURL: String
    private var apiToken: String

    private init() {
        // Load from UserDefaults or use placeholder
        self.baseURL = UserDefaults.standard.string(forKey: "aiServiceBaseURL") ?? "https://your-worker.workers.dev"
        self.apiToken = UserDefaults.standard.string(forKey: "aiServiceAPIToken") ?? ""
    }

    /// Configure the service with backend URL and API token
    static func configure(baseURL: String, apiToken: String) {
        shared.baseURL = baseURL
        shared.apiToken = apiToken
        UserDefaults.standard.set(baseURL, forKey: "aiServiceBaseURL")
        UserDefaults.standard.set(apiToken, forKey: "aiServiceAPIToken")
    }

    var isConfigured: Bool {
        !baseURL.contains("your-worker") && !apiToken.isEmpty
    }

    // MARK: - Chat

    func chat(messages: [(role: String, content: String)]) async throws -> String {
        guard let url = URL(string: "\(baseURL)/ai/chat") else {
            throw AIServiceError.invalidURL
        }

        let messagesPayload = messages.map { ["role": $0.role, "content": $0.content] }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = ["messages": messagesPayload]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.requestFailed
        }

        let result = try JSONDecoder().decode([String: String].self, from: data)
        return result["reply"] ?? "I'm here for you."
    }

    // MARK: - Message Polish

    func polishMessage(_ text: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/ai/message-polish") else {
            throw AIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

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

    // MARK: - Daily Prompt

    func getDailyPrompt() async throws -> String {
        guard let url = URL(string: "\(baseURL)/ai/daily-prompt") else {
            throw AIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.requestFailed
        }

        let result = try JSONDecoder().decode([String: String].self, from: data)
        return result["prompt"] ?? "What's on your mind today?"
    }

    // MARK: - Weekly Summary

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
        request.timeoutInterval = 30

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

enum AIServiceError: LocalizedError {
    case invalidURL
    case requestFailed
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL. Please check your backend configuration."
        case .requestFailed:
            return "Request failed. Please check your connection and try again."
        case .notConfigured:
            return "AI service is not configured. Please set up your backend URL in Settings."
        }
    }
}
