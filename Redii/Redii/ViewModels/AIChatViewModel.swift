import Foundation
import SwiftUI

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [AIMessage] = []
    @Published var inputText: String = ""
    @Published var isProcessing: Bool = false
    @Published var error: Error?
    @Published var selectedInputType: InputType = .text

    var selectedImage: UIImage?
    var selectedVideoURL: URL?
    var selectedVoiceURL: URL?
    var selectedFileURL: URL?

    enum InputType {
        case text
        case voice
        case image
        case video
        case file
    }

    private let aiService = AIService.shared

    func sendMessage() async {
        guard !inputText.isEmpty || hasAttachments() else { return }

        var attachments: [AIMessage.Attachment] = []

        if let image = selectedImage,
           let data = image.jpegData(compressionQuality: 0.8) {
            let url = saveImageData(data)
            attachments.append(.init(type: .image, url: url, name: "image.jpg"))
        }

        if let voiceURL = selectedVoiceURL {
            attachments.append(.init(type: .voice, url: voiceURL, name: "voice.m4a"))
        }

        if let videoURL = selectedVideoURL {
            attachments.append(.init(type: .video, url: videoURL, name: "video.mp4"))
        }

        if let fileURL = selectedFileURL {
            attachments.append(.init(type: .file, url: fileURL, name: fileURL.lastPathComponent))
        }

        let userMessage = AIMessage.userMessage(content: inputText, attachments: attachments.isEmpty ? nil : attachments)
        messages.append(userMessage)

        let currentInput = inputText
        inputText = ""
        clearAttachments()

        isProcessing = true

        do {
            // Build conversation history for the AI
            let conversationHistory = messages.compactMap { msg -> (role: String, content: String)? in
                guard !msg.content.isEmpty else { return nil }
                return (role: msg.role.rawValue, content: msg.content)
            }

            let response: String
            if aiService.isConfigured {
                response = try await aiService.chat(messages: conversationHistory)
            } else {
                // Offline fallback — provide a helpful local response
                response = offlineResponse(for: currentInput)
            }

            let assistantMessage = AIMessage.assistantMessage(content: response)
            messages.append(assistantMessage)
        } catch {
            self.error = error
            let errorMessage = AIMessage.assistantMessage(content: "Sorry, I couldn't connect right now. Please try again later.")
            messages.append(errorMessage)
        }

        isProcessing = false
    }

    func addImage(_ image: UIImage) {
        selectedImage = image
    }

    func addVideo(url: URL) {
        selectedVideoURL = url
    }

    func addVoice(url: URL) {
        selectedVoiceURL = url
    }

    func addFile(url: URL) {
        selectedFileURL = url
    }

    func hasAttachments() -> Bool {
        return selectedImage != nil || selectedVoiceURL != nil || selectedVideoURL != nil || selectedFileURL != nil
    }

    private func clearAttachments() {
        selectedImage = nil
        selectedVoiceURL = nil
        selectedVideoURL = nil
        selectedFileURL = nil
        selectedInputType = .text
    }

    private func saveImageData(_ data: Data) -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(UUID().uuidString + ".jpg")
        try? data.write(to: fileURL)
        return fileURL
    }

    /// Provides gentle offline responses when the backend isn't configured
    private func offlineResponse(for input: String) -> String {
        let lowered = input.lowercased()
        if lowered.contains("date") || lowered.contains("idea") {
            return "How about a cozy movie night, a sunset walk, or cooking something new together? The best dates are the ones where you're simply present with each other."
        } else if lowered.contains("love") || lowered.contains("feel") {
            return "It's beautiful that you're thinking about your feelings. Taking a moment to reflect on what you love about each other can strengthen your bond."
        } else if lowered.contains("fight") || lowered.contains("argue") || lowered.contains("angry") {
            return "Disagreements are normal in any relationship. Try to listen with an open heart, express your feelings calmly, and remember you're on the same team."
        } else if lowered.contains("miss") || lowered.contains("distance") {
            return "Distance can be tough, but it also reminds us how much we value each other. A sweet message or surprise call can bridge the miles."
        } else {
            return "I'm here to help you and your partner grow closer. You can ask me for date ideas, relationship tips, or just share what's on your mind."
        }
    }
}
