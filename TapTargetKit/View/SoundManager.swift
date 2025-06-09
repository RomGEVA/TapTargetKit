import AVFoundation

class SoundManager {
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        if let soundURL = Bundle.main.url(forResource: "bubble", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound: \(error.localizedDescription)")
            }
        }
    }
    
    func playBubbleSound() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
} 