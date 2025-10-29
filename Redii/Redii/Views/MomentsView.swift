import SwiftUI

struct MomentsView: View {
    @EnvironmentObject var diContainer: DIContainer
    @StateObject private var viewModel: MomentsViewModel
    @State private var showingAddMoment = false
    
    init() {
        let di = DIContainer()
        _viewModel = StateObject(wrappedValue: MomentsViewModel(
            momentRepository: di.momentRepository,
            currentUserID: di.currentUser.id
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                filterBar
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.moments.isEmpty {
                    emptyState
                } else {
                    momentList
                }
            }
            .navigationTitle("Moments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMoment = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.loadMoments()
            }
            .refreshable {
                await viewModel.loadMoments()
            }
            .sheet(isPresented: $showingAddMoment) {
                AddMomentView()
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "All", isSelected: viewModel.selectedFilter == nil) {
                    viewModel.selectedFilter = nil
                    Task { await viewModel.loadMoments() }
                }
                
                ForEach(Moment.MomentType.allCases, id: \.self) { type in
                    FilterChip(title: type.rawValue.capitalized, isSelected: viewModel.selectedFilter == type) {
                        viewModel.selectedFilter = type
                        Task { await viewModel.loadMoments() }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var momentList: some View {
        List(viewModel.moments) { moment in
            MomentCard(moment: moment)
                .swipeActions {
                    Button(role: .destructive) {
                        Task { await viewModel.deleteMoment(moment) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .listStyle(.plain)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No moments yet")
                .font(.headline)
            Text("Start recording your memories together")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct MomentCard: View {
    let moment: Moment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(moment.type.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(moment.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(moment.content)
                .font(.body)
            
            if let mood = moment.mood {
                HStack {
                    Text(mood.emoji)
                        .font(.title2)
                    Text(mood.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    MomentsView()
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}

