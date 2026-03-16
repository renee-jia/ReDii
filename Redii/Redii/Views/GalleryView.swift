import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var diContainer: DIContainer
    @StateObject private var viewModel: MomentsViewModel
    @State private var selectedMoment: Moment?

    init() {
        let di = DIContainer()
        _viewModel = StateObject(wrappedValue: MomentsViewModel(
            momentRepository: di.momentRepository,
            currentUserID: di.currentUser.id
        ))
    }

    private var mediaMoments: [Moment] {
        viewModel.moments.filter { $0.type == .photo || $0.type == .voice }
    }

    var body: some View {
        NavigationStack {
            Group {
                if mediaMoments.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100), spacing: 2)
                        ], spacing: 2) {
                            ForEach(mediaMoments) { moment in
                                GalleryItem(moment: moment)
                                    .onTapGesture {
                                        selectedMoment = moment
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Memory Gallery")
            .task {
                await viewModel.loadMoments()
            }
            .refreshable {
                await viewModel.loadMoments()
            }
            .sheet(item: $selectedMoment) { moment in
                MomentDetailView(moment: moment)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No media yet")
                .font(.headline)
            Text("Photos and voice notes will appear here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GalleryItem: View {
    let moment: Moment

    var body: some View {
        Rectangle()
            .fill(Color(UIColor.systemGray6))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let photoURL = moment.photoURL,
                   let data = try? Data(contentsOf: photoURL),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if moment.photoURL != nil {
                    Image(systemName: "photo.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                } else if moment.voiceURL != nil {
                    VStack(spacing: 4) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                        Text("Voice")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .clipped()
    }
}

struct MomentDetailView: View {
    let moment: Moment
    @StateObject private var voiceService = VoiceService()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let photoURL = moment.photoURL,
                       let data = try? Data(contentsOf: photoURL),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else if moment.photoURL != nil {
                        Rectangle()
                            .fill(Color(UIColor.systemGray6))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(.secondary)
                            }
                    }

                    if let voiceURL = moment.voiceURL {
                        VStack(spacing: 8) {
                            Button(action: {
                                try? voiceService.togglePlayback(from: voiceURL)
                            }) {
                                HStack {
                                    Image(systemName: voiceService.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                        .font(.title)
                                    Text(voiceService.isPlaying ? "Stop" : "Play Voice Note")
                                        .font(.headline)
                                }
                            }

                            if voiceService.isPlaying {
                                ProgressView(value: voiceService.playbackProgress, total: 60)
                                    .tint(.blue)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    }

                    if !moment.content.isEmpty {
                        Text(moment.content)
                            .font(.body)
                    }

                    if let mood = moment.mood {
                        HStack {
                            Text(mood.emoji)
                                .font(.title)
                            Text(mood.label)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(moment.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    GalleryView()
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}
