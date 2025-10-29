import SwiftUI

struct ChatView: View {
    @EnvironmentObject var diContainer: DIContainer
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    
    init() {
        let di = DIContainer()
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            chatRepository: di.chatRepository,
            currentUserID: di.currentUser.id
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            if viewModel.messages.isEmpty {
                                emptyState
                            } else {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message, isFromCurrentUser: message.senderID == diContainer.currentUser.id)
                                        .id(message.id)
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                messageInputBar
            }
            .navigationTitle("Whispers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadMessages()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No messages yet")
                .font(.headline)
            Text("Start whispering")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.newMessageText)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                Task { await viewModel.sendMessage() }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(viewModel.newMessageText.isEmpty ? .secondary : .blue)
            }
            .disabled(viewModel.newMessageText.isEmpty)
        }
        .padding()
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if !isFromCurrentUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(18)
                
                if let reaction = message.reaction {
                    Text(reaction)
                        .font(.caption)
                }
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if isFromCurrentUser {
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}

