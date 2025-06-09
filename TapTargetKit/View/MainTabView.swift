import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var gameModel = GameModel()
    @StateObject private var levelManager = LevelManager()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    NavigationView { GameView() }
                        .environmentObject(gameModel)
                        .environmentObject(levelManager)
                case 1:
                    NavigationView { LevelMenuView(selectedTab: $selectedTab) }
                        .environmentObject(gameModel)
                        .environmentObject(levelManager)
                case 2:
                    NavigationView { GameFactsView() }
                        .environmentObject(gameModel)
                        .environmentObject(levelManager)
                case 3:
                    NavigationView { SettingsView() }
                        .environmentObject(gameModel)
                        .environmentObject(levelManager)
                default:
                    EmptyView()
                }
            }
            .edgesIgnoringSafeArea(.all)
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 