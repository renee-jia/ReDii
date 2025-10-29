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
            attachments.append(.init(type: .file, url: fileURL, name: "file"))
        }
        
        let userMessage = AIMessage.userMessage(content: inputText, attachments: attachments.isEmpty ? nil : attachments)
        messages.append(userMessage)
        
        let currentInput = inputText
        inputText = ""
        clearAttachments()
        
        isProcessing = true
        
        do {
            if attachments.isEmpty {
                let response = try await aiService.polishMessage(currentInput)
                let assistantMessage = AIMessage.assistantMessage(content: response)
                messages.append(assistantMessage)
            } else {
                let assistantMessage = AIMessage.assistantMessage(content: "I received your message with attachments!")
                messages.append(assistantMessage)
            }
        } catch {
            self.error = error
            let errorMessage = AIMessage.assistantMessage(content: "Sorry, I encountered an error. Please try again.")
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
}
