import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Tap the Target")
                .font(.largeTitle)
                .bold()
            
            Text("Tap the target as fast as you can!")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                hasSeenOnboarding = true
                dismiss()
            }) {
                Text("Let's Play!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding(.bottom, 50)
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
} 