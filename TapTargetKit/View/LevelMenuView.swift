import SwiftUI

struct LevelMenuView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var gameModel: GameModel
    @EnvironmentObject var levelManager: LevelManager
    @Environment(\.dismiss) private var dismiss
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(levelManager.levels) { level in
                    LevelButton(level: level) {
                        levelManager.selectLevel(level)
                        gameModel.startGame(level: level)
                        selectedTab = 0 // Switch to Game tab
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Levels")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LevelButton: View {
    let level: Level
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(level.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(level.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text("\(level.requiredTaps) taps")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(
                level.isUnlocked ?
                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                LinearGradient(colors: [.gray, .gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(15)
            .shadow(radius: 5)
            .opacity(level.isUnlocked ? 1 : 0.7)
        }
        .disabled(!level.isUnlocked)
    }
}

struct LevelMenuView_Previews: PreviewProvider {
    static var previews: some View {
        LevelMenuView(selectedTab: .constant(1))
            .environmentObject(GameModel())
            .environmentObject(LevelManager())
    }
} 