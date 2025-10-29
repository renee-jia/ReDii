import SwiftUI
import PhotosUI

struct AddMomentView: View {
    @EnvironmentObject var diContainer: DIContainer
    @State private var content: String = ""
    @State private var selectedType: Moment.MomentType = .note
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isRecordingVoice = false
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
                                Text("Select Photo")
                                Spacer()
                                Image(systemName: "photo")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                
                if selectedType == .voice {
                    Section {
                        HStack {
                            Button(action: {
                                isRecordingVoice.toggle()
                            }) {
                                HStack {
                                    Image(systemName: isRecordingVoice ? "stop.circle.fill" : "mic.circle.fill")
                                        .font(.title)
                                    Text(isRecordingVoice ? "Stop Recording" : "Start Recording")
                                }
                            }
                            .foregroundStyle(isRecordingVoice ? .red : .blue)
                        }
                    }
                }
                
                if selectedType == .mood {
                    Section {
                        MoodSelectionView()
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
    
    private func saveMoment() {
        let moment = Moment(
            id: UUID(),
            type: selectedType,
            content: content,
            createdAt: Date(),
            authorID: diContainer.currentUser.id,
            photoURL: nil,
            voiceURL: nil,
            mood: selectedType == .mood ? Moment.Mood(emoji: "❤️", label: "Loving") : nil
        )
        
        Task {
            try? await diContainer.momentRepository.createMoment(moment)
            dismiss()
        }
    }
}

struct MoodSelectionView: View {
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
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    AddMomentView()
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}

