import SwiftUI

struct GameFactsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("How TapTarget Improves Your Focus")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                // Benefits Section
                Group {
                    FactCard(
                        title: "Enhanced Attention",
                        description: "Regular practice with TapTarget helps improve your ability to focus on specific tasks and ignore distractions.",
                        icon: "brain.head.profile"
                    )
                    
                    FactCard(
                        title: "Better Reaction Time",
                        description: "The game's various mechanics train your brain to process visual information faster and respond more quickly.",
                        icon: "bolt.fill"
                    )
                    
                    FactCard(
                        title: "Improved Concentration",
                        description: "By requiring precise timing and coordination, TapTarget helps develop sustained attention and mental stamina.",
                        icon: "target"
                    )
                    
                    FactCard(
                        title: "Visual Processing",
                        description: "Different level types enhance your ability to process visual information and make quick decisions.",
                        icon: "eye.fill"
                    )
                    
                    FactCard(
                        title: "Cognitive Flexibility",
                        description: "Switching between different game mechanics helps improve your ability to adapt to changing situations.",
                        icon: "arrow.triangle.2.circlepath"
                    )
                }
                
                // Research Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scientific Research")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    
                    Text("Studies have shown that games requiring quick reactions and focused attention can lead to:")
                        .foregroundColor(.secondary)
                    
                    BulletPoint(text: "Improved attention span")
                    BulletPoint(text: "Better multitasking abilities")
                    BulletPoint(text: "Enhanced visual processing")
                    BulletPoint(text: "Increased mental flexibility")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                
                // Tips Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tips for Maximum Benefits")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    
                    BulletPoint(text: "Play regularly for short sessions")
                    BulletPoint(text: "Focus on accuracy rather than speed")
                    BulletPoint(text: "Take breaks between sessions")
                    BulletPoint(text: "Challenge yourself with harder levels")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
            }
            .padding()
        }
        .navigationTitle("Game Benefits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FactCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .font(.title2)
                .foregroundColor(.blue)
            Text(text)
                .font(.body)
        }
    }
}

struct GameFactsView_Previews: PreviewProvider {
    static var previews: some View {
        GameFactsView()
    }
} 