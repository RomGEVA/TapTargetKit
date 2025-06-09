import SwiftUI

struct RateAppView: View {
    @State private var rating: Int = 0
    @State private var submitted = false
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Rate the App")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            Text("How do you like the game?")
                .font(.title3)
                .foregroundColor(.gray)
            HStack(spacing: 18) {
                ForEach(1...5, id: \ .self) { idx in
                    Image(systemName: rating >= idx ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(rating >= idx ? .yellow : .gray.opacity(0.5))
                        .scaleEffect(rating == idx ? 1.2 : 1.0)
                        .animation(.spring(), value: rating)
                        .onTapGesture {
                            rating = idx
                        }
                }
            }
            if submitted {
                Text("Thank you for your feedback!")
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding(.top, 16)
            } else {
                Button(action: {
                    submitted = true
                }) {
                    Text("Submit")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(rating > 0 ? Color.blue : Color.gray)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .disabled(rating == 0)
            }
            Spacer()
        }
        .padding()
    }
}

struct RateAppView_Previews: PreviewProvider {
    static var previews: some View {
        RateAppView()
    }
} 
