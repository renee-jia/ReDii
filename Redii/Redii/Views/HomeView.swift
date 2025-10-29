import SwiftUI

struct HomeView: View {
    @EnvironmentObject var diContainer: DIContainer
    @StateObject private var viewModel: HomeViewModel
    @State private var showingMomentSheet = false
    @State private var showingChat = false
    @State private var showingAIChat = false
    
    init() {
        let di = DIContainer()
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            momentRepository: di.momentRepository,
            appSettings: di.appSettings,
            anniversaryDate: nil
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    daysTogetherSection
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Center")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showingAIChat = true }) {
                            Image(systemName: "sparkles")
                        }
                        Button(action: { showingChat = true }) {
                            Image(systemName: "message.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingMomentSheet) {
                AddMomentView()
            }
            .sheet(isPresented: $showingChat) {
                ChatView()
            }
            .sheet(isPresented: $showingAIChat) {
                AIChatView()
            }
        }
        .onAppear {
            viewModel.loadDaysTogether()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Two hearts. One center.")
                .font(.title2)
            Text("\(viewModel.daysTogether) days together")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var daysTogetherSection: some View {
        Text("\(viewModel.daysTogether)")
            .font(.system(size: 72, weight: .ultraLight))
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Button(action: { showingMomentSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Moment")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: { showingAIChat = true }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("AI Chat")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.bordered)
            
            Button(action: { showingChat = true }) {
                HStack {
                    Image(systemName: "message.circle.fill")
                    Text("Partner Chat")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DIContainer(useInMemoryRepositories: true))
}

