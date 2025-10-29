import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    @State private var showingFilePicker = false
    @State private var showingVoiceRecorder = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                MessageRow(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isProcessing {
                                ProcessingIndicator()
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
                
                if viewModel.hasAttachments() {
                    attachmentPreview
                }
                
                Divider()
                
                inputArea
            }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: Binding(
                    get: { viewModel.selectedImage },
                    set: { viewModel.selectedImage = $0 }
                ))
            }
            .sheet(isPresented: $showingVideoPicker) {
                DocumentPicker(contentTypes: [.movie]) { url in
                    if let url = url {
                        viewModel.addVideo(url: url)
                    }
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(contentTypes: [.data]) { url in
                    if let url = url {
                        viewModel.addFile(url: url)
                    }
                }
            }
        }
    }
    
    private var attachmentPreview: some View {
        HStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            if viewModel.selectedVoiceURL != nil {
                Label("Voice", systemImage: "waveform")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if viewModel.selectedVideoURL != nil {
                Label("Video", systemImage: "video")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if viewModel.selectedFileURL != nil {
                Label("File", systemImage: "doc")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.selectedImage = nil
                viewModel.selectedVoiceURL = nil
                viewModel.selectedVideoURL = nil
                viewModel.selectedFileURL = nil
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var inputArea: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button(action: { showInputTypePicker() }) {
                    Image(systemName: iconForInputType())
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                
                TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...6)
                
                if !viewModel.inputText.isEmpty || viewModel.hasAttachments() {
                    Button(action: {
                        Task { await viewModel.sendMessage() }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            inputTypeButtons
        }
    }
    
    private var inputTypeButtons: some View {
        HStack(spacing: 20) {
            Button(action: { showingImagePicker = true }) {
                Label("Photo", systemImage: "photo")
                    .font(.caption)
            }
            
            Button(action: { showingVideoPicker = true }) {
                Label("Video", systemImage: "video")
                    .font(.caption)
            }
            
            Button(action: { showingVoiceRecorder = true }) {
                Label("Voice", systemImage: "mic")
                    .font(.caption)
            }
            
            Button(action: { showingFilePicker = true }) {
                Label("File", systemImage: "doc")
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private func iconForInputType() -> String {
        switch viewModel.selectedInputType {
        case .text: return "keyboard"
        case .voice: return "mic"
        case .image: return "photo"
        case .video: return "video"
        case .file: return "doc"
        }
    }
    
    private func showInputTypePicker() {
        viewModel.selectedInputType = .text
    }
}

struct MessageRow: View {
    let message: AIMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                if let attachments = message.attachments, !attachments.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(attachments) { attachment in
                                AttachmentView(attachment: attachment)
                            }
                        }
                    }
                }
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.role == .user ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .cornerRadius(20)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
    }
}

struct AttachmentView: View {
    let attachment: AIMessage.Attachment
    
    var body: some View {
        switch attachment.type {
        case .image:
            AsyncImage(url: attachment.url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color(.systemGray5)
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
        case .voice:
            VoiceAttachmentView(url: attachment.url)
            
        case .video:
            VideoAttachmentView(url: attachment.url)
            
        case .file:
            FileAttachmentView(url: attachment.url, name: attachment.name)
        }
    }
}

struct VoiceAttachmentView: View {
    let url: URL
    @State private var isPlaying = false
    
    var body: some View {
        HStack {
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title)
            }
            
            VStack(alignment: .leading) {
                Text("Voice Message")
                    .font(.subheadline)
                Text(url.lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct VideoAttachmentView: View {
    let url: URL
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(width: 200, height: 200)
            .overlay {
                VStack {
                    Image(systemName: "video.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
    }
}

struct FileAttachmentView: View {
    let url: URL
    let name: String
    
    var body: some View {
        HStack {
            Image(systemName: fileIcon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                Text(fileSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var fileIcon: String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "doc.text.fill"
        case "doc", "docx": return "doc.fill"
        case "jpg", "jpeg", "png": return "photo.fill"
        default: return "doc.fill"
        }
    }
    
    private var fileSize: String {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attributes[.size] as? Int64 {
            let formatter = ByteCountFormatter()
            return formatter.string(fromByteCount: size)
        }
        return "Unknown size"
    }
}

struct ProcessingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.2), value: isAnimating)
                    
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.4), value: isAnimating)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .cornerRadius(20)
            }
            .onAppear { isAnimating = true }
            
            Spacer(minLength: 60)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let onPick: (URL?) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.onPick(url)
            } else {
                parent.onPick(nil)
            }
            parent.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onPick(nil)
            parent.dismiss()
        }
    }
}

#Preview {
    AIChatView()
}

