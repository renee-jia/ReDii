import SwiftUI

struct AIChatDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("AI Chat UI 演示")
                    .font(.largeTitle)
                    .bold()
                
                DemoSection()
                DemoSection2()
                DemoSection3()
            }
            .padding()
        }
    }
}

struct DemoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. 消息样式")
                .font(.title2)
                .bold()
            
            VStack(alignment: .trailing, spacing: 8) {
                MessageBubble(demo: .user(text: "Today was nice"))
                Text("10:23 AM")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                MessageBubble(demo: .assistant(text: "Today was absolutely wonderful, filled with simple, beautiful moments that make my heart smile."))
                Text("10:23 AM")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct DemoSection2: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2. 附件预览")
                .font(.title2)
                .bold()
            
            HStack {
                AsyncImage(url: URL(string: "https://via.placeholder.com/150")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                HStack {
                    Image(systemName: "waveform")
                    Text("Voice message")
                        .font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
        }
    }
}

struct DemoSection3: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("3. 输入区域")
                .font(.title2)
                .bold()
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "keyboard")
                        .foregroundStyle(.blue)
                    
                    Text("Type a message...")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                
                HStack(spacing: 20) {
                    Button { } label: {
                        Label("Photo", systemImage: "photo")
                            .font(.caption)
                    }
                    
                    Button { } label: {
                        Label("Video", systemImage: "video")
                            .font(.caption)
                    }
                    
                    Button { } label: {
                        Label("Voice", systemImage: "mic")
                            .font(.caption)
                    }
                    
                    Button { } label: {
                        Label("File", systemImage: "doc")
                            .font(.caption)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct MessageBubble: View {
    enum DemoType {
        case user(text: String)
        case assistant(text: String)
    }
    
    let demo: DemoType
    
    var body: some View {
        HStack {
            if case .assistant = demo {
                Spacer(minLength: 40)
            }
            
            Text(content)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .cornerRadius(20)
            
            if case .user = demo {
                Spacer(minLength: 40)
            }
        }
    }
    
    private var content: String {
        switch demo {
        case .user(let text):
            return text
        case .assistant(let text):
            return text
        }
    }
    
    private var backgroundColor: Color {
        switch demo {
        case .user:
            return .blue
        case .assistant:
            return Color(.systemGray5)
        }
    }
    
    private var foregroundColor: Color {
        switch demo {
        case .user:
            return .white
        case .assistant:
            return .primary
        }
    }
}

#Preview {
    AIChatDemoView()
}

