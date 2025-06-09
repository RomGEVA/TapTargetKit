import SwiftUI

struct SettingsView: View {
    @AppStorage("isSoundEnabled") private var isSoundEnabled = true
    @Environment(\.dismiss) private var dismiss
    @State private var showRateApp = false
    @State private var showResetAlert = false
    @State private var showGameFacts = false
    @EnvironmentObject var levelManager: LevelManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Game Settings")) {
                    Toggle("Sound Effects", isOn: $isSoundEnabled)
                }
                
                Section(header: Text("Progress")) {
                    Button(action: { showResetAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise").foregroundColor(.red)
                            Text("Reset Progress")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    Button(action: { showGameFacts = true }) {
                        HStack {
                            Image(systemName: "brain.head.profile").foregroundColor(.blue)
                            Text("Game Benefits")
                        }
                    }
                    Button(action: { showRateApp = true }) {
                        HStack {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                            Text("Rate the App")
                        }
                    }
                    Link("Privacy Policy", destination: URL(string: "https://www.termsfeed.com/live/ccbb0268-eb81-4028-b255-5b8be1cdc7f7")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showRateApp) {
                RateAppView()
            }
            .sheet(isPresented: $showGameFacts) {
                GameFactsView()
            }
            .alert("Reset Progress", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    levelManager.resetProgress()
                }
            } message: {
                Text("Are you sure you want to reset all progress? This will unlock only the first level.")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 
