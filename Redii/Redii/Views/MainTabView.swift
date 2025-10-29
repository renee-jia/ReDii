import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var diContainer: DIContainer
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            MomentsView()
                .tabItem {
                    Label("Moments", systemImage: "photo.on.rectangle.angled")
                }
                .tag(1)
            
            AIChatView()
                .tabItem {
                    Label("AI Chat", systemImage: "message.fill")
                }
                .tag(2)
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.bubble.fill")
                }
                .tag(3)
            
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.stack.fill")
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
    }
}

