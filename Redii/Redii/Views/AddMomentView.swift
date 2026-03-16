import SwiftUI
import PhotosUI

struct AddMomentView: View {
    @EnvironmentObject var diContainer: DIContainer
    @State private var content: String = ""
    @State private var selectedType: Moment.MomentType = .note
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var selectedMood: (String, String)?
    @StateObject private var voiceService = VoiceService()
    @State private var recordingURL: URL?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $selectedType) {
                        ForEach(Moment.MomentType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                }

                Section {
                    TextField("What's on your mind?", text: $content, axis: .vertical)
                        .lineLimit(3...6)
                }

                if selectedType == .photo {
                    Section {
                        PhotosPicker(selection: $selectedPhotoItem) {
                            HStack {
                                if selectedPhotoData != nil {
                                    Text("Photo selected")
                                        .foregroundStyle(.green)
                                } else {
                                    Text("Select Photo")
                                }
                                Spacer()
                                Image(systemName: selectedPhotoData != nil ? "checkmark.circle.fill" : "photo")
                                    .foregroundStyle(selectedPhotoData != nil ? .green : .blue)
                            }
                        }
                        .onChange(of: selectedPhotoItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedPhotoData = data
                                }
                            }
                        }

                        if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }

                if selectedType == .voice {
                    Section {
                        VStack(spacing: 12) {
                            HStack {
                                Button(action: toggleRecording) {
                                    HStack {
                                        Image(systemName: voiceService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                            .font(.title)
                                        Text(voiceService.isRecording ? "Stop Recording" : "Start Recording")
                                    }
                                }
                                .foregroundStyle(voiceService.isRecording ? .red : .blue)

                                Spacer()

                                if voiceService.isRecording {
                                    Text(voiceService.formattedDuration(voiceService.recordingDuration))
                                        .font(.headline)
                                        .monospacedDigit()
                                        .foregroundStyle(.red)
                                }
                            }

                            if let url = recordingURL, !voiceService.isRecording {
                                HStack {
                                    Button(action: {
                                        try? voiceService.togglePlayback(from: url)
                                    }) {
                                        HStack {
                                            Image(systemName: voiceService.isPlaying ? "stop.fill" : "play.fill")
                                            Text(voiceService.isPlaying ? "Stop" : "Play Recording")
                                        }
                                    }
                                    .foregroundStyle(.blue)

                                    Spacer()

                                    Button(role: .destructive) {
                                        recordingURL = nil
                                        try? FileManager.default.removeItem(at: url)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }
                }

                if selectedType == .mood {
                    Section {
                        MoodSelectionView(selectedMood: $selectedMood)
                    }
                }
            }
            .navigationTitle("New Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMoment()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }

    private func toggleRecording() {
        if voiceService.isRecording {
            recordingURL = voiceService.stopRecording()
        } else {
            recordingURL = try? voiceService.startRecording()
        }
    }

    private func saveMoment() {
        // Save photo data to file if present
        var photoURL: URL?
        if let data = selectedPhotoData {
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = docsDir.appendingPathComponent("\(UUID().uuidString).jpg")
            try? data.write(to: fileURL)
            photoURL = fileURL
        }

        let mood: Moment.Mood?
        if selectedType == .mood, let selected = selectedMood {
            mood = Moment.Mood(emoji: selected.0, label: selected.1)
        } else {
            mood = nil
        }

        let moment = Moment(
            id: UUID(),
            type: selectedType,
            content: content,
            createdAt: Date(),
            authorID: diContainer.currentUser.id,
            photoURL: photoURL,
            voiceURL: recordingURL,
            mood: mood
        )

        Task {
            try? await diContainer.momentRepository.createMoment(moment)
            dismiss()
        }
    }
}

struct MoodSelectionView: View {
    @Binding var selectedMood: (String, String)?

    let moods: [(String, String)] = [
        ("❤️", "Loving"),
        ("😊", "Happy"),
        ("😍", "Excited"),
        ("🥰", "Adorable"),
        ("😴", "Sleepy")
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
            ForEach(moods, id: \.0) { emoji, label in
                VStack {
                    Text(emoji)
                        .font(.system(size: 48))
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    selectedMood?.0 == emoji
                        ? Color.accentColor.opacity(0.2)
                        : Color(UIColor.systemGray6)
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedMood?.0 == emoji ? Color.accentColor : .clear, lineWidth: 2)
                )
                .onTapGesture {
                    selectedMood = (emoji, label)
                }
            }
        }
    }
}

struct AddMomentView_Previews: PreviewProvider {
    static var previews: some View {
        AddMomentView()
            .environmentObject(DIContainer(useInMemoryRepositories: true))
    }
}
