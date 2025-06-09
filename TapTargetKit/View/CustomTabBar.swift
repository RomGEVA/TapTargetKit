import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let icons = ["target", "list.number", "brain.head.profile", "gearshape"]
    let titles = ["Game", "Levels", "Benefits", "Settings"]
    
    var body: some View {
        HStack {
            ForEach(0..<4) { idx in
                Button(action: {
                    withAnimation(.spring()) { selectedTab = idx }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: icons[idx])
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(selectedTab == idx ? Color.blue : Color.gray)
                            .scaleEffect(selectedTab == idx ? 1.2 : 1.0)
                        Text(titles[idx])
                            .font(.caption)
                            .foregroundColor(selectedTab == idx ? Color.blue : Color.gray)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(color: .black.opacity(0.08), radius: 8, y: -2)
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(0))
    }
} 