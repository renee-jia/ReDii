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
    
    private var photoMoments: [Moment] {
        viewModel.moments.filter { $0.type == .photo || $0.type == .voice }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100), spacing: 2)
                ], spacing: 2) {
                    ForEach(photoMoments) { moment in
                        GalleryItem(moment: moment)
                            .onTapGesture {
                                selectedMoment = moment
                            }
                    }
                }
            }
            .navigationTitle("Memory Gallery")
            .task {
                await viewModel.loadMoments()
            }
            .sheet(item: $selectedMoment) { moment in
                MomentDetailView(moment: moment)
            }
        }
    }
}

struct GalleryItem: View {
    let moment: Moment
    
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if moment.photoURL != nil {
                    Image(systemName: "photo.fill")
                        .foregroundStyle(.secondary)
                } else if moment.voiceURL != nil {
                    Image(systemName: "waveform.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
    }
}

struct MomentDetailView: View {
    let moment: Moment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if moment.photoURL != nil {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(.secondary)
                            }
                    }
                    
                    Text(moment.content)
                        .font(.body)
                    
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

