import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @StateObject private var voiceService = VoiceService()
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    @State private var showingFilePicker = false
    @State private var isRecordingVoice = false
    @State private var voiceRecordingURL: URL?

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

                if viewModel.hasAttachments() || voiceRecordingURL != nil {
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

            if voiceRecordingURL != nil || viewModel.selectedVoiceURL != nil {
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                    Text("Voice")
                }
                .font(.caption)
                .foregroundStyle(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
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

            Button(action: clearAllAttachments) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGray6))
    }

    private var inputArea: some View {
        VStack(spacing: 8) {
            // Voice recording indicator
            if isRecordingVoice {
                HStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text("Recording \(voiceService.formattedDuration(voiceService.recordingDuration))")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .monospacedDigit()
                    Spacer()
                    Button("Cancel") {
                        stopVoiceRecording(discard: true)
                    }
                    .font(.caption)
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }

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
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...6)

                if !viewModel.inputText.isEmpty || viewModel.hasAttachments() || voiceRecordingURL != nil {
                    Button(action: {
                        if let url = voiceRecordingURL {
                            viewModel.addVoice(url: url)
                            voiceRecordingURL = nil
                        }
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

            Button(action: toggleVoiceRecording) {
                Label(
                    isRecordingVoice ? "Stop" : "Voice",
                    systemImage: isRecordingVoice ? "stop.circle.fill" : "mic"
                )
                .font(.caption)
                .foregroundStyle(isRecordingVoice ? .red : .blue)
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

    private func toggleVoiceRecording() {
        if isRecordingVoice {
            stopVoiceRecording(discard: false)
        } else {
            voiceRecordingURL = try? voiceService.startRecording()
            isRecordingVoice = voiceService.isRecording
        }
    }

    private func stopVoiceRecording(discard: Bool) {
        let url = voiceService.stopRecording()
        isRecordingVoice = false
        if discard {
            if let url = url {
                try? FileManager.default.removeItem(at: url)
            }
            voiceRecordingURL = nil
        } else {
            voiceRecordingURL = url
        }
    }

    private func clearAllAttachments() {
        viewModel.selectedImage = nil
        viewModel.selectedVoiceURL = nil
        viewModel.selectedVideoURL = nil
        viewModel.selectedFileURL = nil
        if let url = voiceRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        voiceRecordingURL = nil
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
            if let data = try? Data(contentsOf: attachment.url),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                AsyncImage(url: attachment.url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

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
    @StateObject private var voiceService = VoiceService()

    var body: some View {
        HStack {
            Button(action: {
                try? voiceService.togglePlayback(from: url)
            }) {
                Image(systemName: voiceService.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title)
            }

            VStack(alignment: .leading) {
                Text("Voice Message")
                    .font(.subheadline)
                if voiceService.isPlaying {
                    Text(voiceService.formattedDuration(voiceService.playbackProgress))
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.blue)
                } else {
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
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
        .background(Color(UIColor.systemGray6))
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
