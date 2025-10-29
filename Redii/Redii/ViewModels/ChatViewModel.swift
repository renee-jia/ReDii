import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var newMessageText: String = ""
    @Published var isLoading: Bool = false
    
    private let chatRepository: ChatRepositoryProtocol
    private let currentUserID: UUID
    
    init(chatRepository: ChatRepositoryProtocol, currentUserID: UUID) {
        self.chatRepository = chatRepository
        self.currentUserID = currentUserID
    }
    
    func loadMessages() async {
        isLoading = true
        
        do {
            messages = try await chatRepository.fetchMessages()
        } catch {
            print("Failed to load messages: \(error)")
        }
        
        isLoading = false
    }
    
    func sendMessage() async {
        guard !newMessageText.isEmpty else { return }
        
        let message = ChatMessage.create(text: newMessageText, senderID: currentUserID)
        
        do {
            try await chatRepository.sendMessage(message)
            await loadMessages()
            newMessageText = ""
        } catch {
            print("Failed to send message: \(error)")
        }
    }
    
    func addReaction(_ reaction: String, to message: ChatMessage) async {
        do {
            try await chatRepository.addReaction(reaction, to: message.id)
            await loadMessages()
        } catch {
            print("Failed to add reaction: \(error)")
        }
    }
}

