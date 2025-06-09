import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameModel: GameModel
    @EnvironmentObject var levelManager: LevelManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var shouldRestart = false
    
    func colorName(_ color: Color) -> String {
        switch color {
        case .red: return "RED"
        case .green: return "GREEN"
        case .blue: return "BLUE"
        default: return "COLOR"
        }
    }
    
    private func autoStartGameIfNeeded() {
        if !gameModel.isGameActive {
            if levelManager.currentLevel == nil {
                if let lastUnlocked = levelManager.lastUnlockedLevel() {
                    levelManager.selectLevel(lastUnlocked)
                    gameModel.startGame(level: lastUnlocked)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Score and timer
                HStack {
                    Text("Score: \(gameModel.score)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(15)
                    
                    Spacer()
                    
                    Text("Time: \(gameModel.timeRemaining)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(15)
                }
                .padding()
                
                // Level-specific UI
                if let level = gameModel.currentLevel {
                    if level.id >= 11 {
                        Text("Tap the \(colorName(gameModel.targetColor)) ball!")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(15)
                    } else {
                        switch level.type {
                        case .tapSequence:
                            Text("Follow the sequence")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(15)
                        default:
                            EmptyView()
                        }
                    }
                }
                
                Spacer()
                
                if !gameModel.isGameActive {
                    VStack(spacing: 20) {
                        if let level = gameModel.currentLevel, gameModel.score >= level.requiredTaps {
                            Text("Level Complete!")
                                .font(.largeTitle)
                                .bold()
                            Text("Your Score: \(gameModel.score)")
                                .font(.title)
                            Text("Required: \(level.requiredTaps)")
                                .font(.title2)
                            if let nextLevel = levelManager.levels.first(where: { $0.id == level.id + 1 }) {
                                Button(action: {
                                    gameModel.nextLevel(levelManager: levelManager)
                                }) {
                                    Text("Next Level")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 220)
                                        .background(Color.green)
                                        .cornerRadius(15)
                                        .shadow(radius: 5)
                                }
                            } else {
                                Button(action: {
                                    if let first = levelManager.levels.first { gameModel.startGame(level: first) }
                                }) {
                                    Text("Restart from Level 1")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 220)
                                        .background(Color.blue)
                                        .cornerRadius(15)
                                        .shadow(radius: 5)
                                }
                            }
                        } else {
                            Text("Game Over!")
                                .font(.largeTitle)
                                .bold()
                            Text("Your Score: \(gameModel.score)")
                                .font(.title)
                            if let level = gameModel.currentLevel {
                                Text("Required: \(level.requiredTaps)")
                                    .font(.title2)
                            }
                            Button(action: {
                                gameModel.retryLevel()
                            }) {
                                Text("Retry")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.orange)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            // Target(s)
            if gameModel.isGameActive, let level = gameModel.currentLevel {
                switch level.type {
                case .tapStatic:
                    if gameModel.isTargetVisible {
                        Circle()
                            .fill(.red)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 5)
                            .scaleEffect(gameModel.targetScale)
                            .position(gameModel.targetPosition)
                            .onTapGesture {
                                gameModel.handleTapOnTarget(color: .red)
                            }
                    }
                case .tapMoving:
                    if gameModel.isTargetVisible {
                        Circle()
                            .fill(.blue)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 5)
                            .scaleEffect(gameModel.targetScale)
                            .position(gameModel.targetPosition)
                            .onTapGesture {
                                gameModel.handleTapOnTarget(color: .blue)
                            }
                    }
                case .tapDisappearing:
                    if gameModel.isTargetVisible {
                        Circle()
                            .fill(.green)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 5)
                            .scaleEffect(gameModel.targetScale)
                            .position(gameModel.targetPosition)
                            .onTapGesture {
                                gameModel.handleTapOnTarget(color: .green)
                            }
                    }
                case .tapColor:
                    HStack(spacing: 40) {
                        ForEach(gameModel.colorChoices, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 5)
                                .scaleEffect(gameModel.targetScale)
                                .onTapGesture {
                                    gameModel.handleTapOnTarget(color: color)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .tapAvoidColor:
                    HStack(spacing: 40) {
                        ForEach(gameModel.colorChoices, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 5)
                                .scaleEffect(gameModel.targetScale)
                                .onTapGesture {
                                    gameModel.handleTapOnTarget(color: color)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .tapSequence:
                    HStack(spacing: 24) {
                        ForEach(gameModel.sequenceNumbers, id: \.self) { number in
                            Circle()
                                .fill(number == gameModel.sequenceNumbers[gameModel.currentSequenceIndex] ? Color.green : Color.gray)
                                .frame(width: 60, height: 60)
                                .overlay(Text("\(number)").foregroundColor(.white).font(.title2).bold())
                                .onTapGesture {
                                    gameModel.handleTapOnSequence(number: number)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .tapPair:
                    HStack(spacing: 40) {
                        ForEach(0..<2, id: \.self) { idx in
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 5)
                                .onTapGesture {
                                    gameModel.handleTapOnPair(selected: [0,1])
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .tapHold:
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 70, height: 70)
                        .shadow(radius: 5)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in gameModel.handleHoldTapBegan() }
                                .onEnded { _ in gameModel.handleHoldTapEnded() }
                        )
                        .overlay(
                            gameModel.isHolding ?
                                Text("Hold...")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .bold() : nil
                        )
                case .tapBlink:
                    if gameModel.blinkVisible {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 5)
                            .onTapGesture {
                                gameModel.handleTapOnBlink()
                            }
                    }
                case .tapSmallest:
                    HStack(spacing: 30) {
                        ForEach(Array(gameModel.ballSizes.enumerated()), id: \.offset) { idx, size in
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: size, height: size)
                                .shadow(radius: 5)
                                .onTapGesture {
                                    gameModel.handleTapOnSmallest(index: idx)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .tapBiggest:
                    HStack(spacing: 30) {
                        ForEach(Array(gameModel.colorChoices.enumerated()), id: \.offset) { idx, color in
                            Circle()
                                .fill(color)
                                .frame(width: gameModel.ballSizes[idx], height: gameModel.ballSizes[idx])
                                .shadow(radius: 5)
                                .onTapGesture {
                                    gameModel.handleTapOnBiggest(index: idx)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .tapChangingColor:
                    Circle()
                        .fill(gameModel.changingColor)
                        .frame(width: 70, height: 70)
                        .shadow(radius: 5)
                        .onTapGesture {
                            gameModel.handleTapOnChangingColor()
                        }
                        .overlay(
                            Text("Tap when pink!")
                                .foregroundColor(.white)
                                .font(.caption)
                                .bold()
                                .padding(.top, 60)
                        )
                case .tapShape:
                    HStack(spacing: 40) {
                        ForEach(["circle", "triangle", "square"], id: \.self) { shape in
                            ZStack {
                                if shape == "circle" {
                                    Circle().fill(Color.blue)
                                } else if shape == "triangle" {
                                    Triangle().fill(Color.green)
                                } else {
                                    RoundedRectangle(cornerRadius: 8).fill(Color.orange)
                                }
                            }
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                gameModel.handleTapOnShape(shape: shape)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .tapFlash:
                    if gameModel.flashVisible {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 5)
                            .onTapGesture {
                                gameModel.handleTapOnFlash()
                            }
                    }
                case .tapRunaway:
                    Circle()
                        .fill(Color.mint)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 5)
                        .position(gameModel.runawayPosition)
                        .onTapGesture {
                            gameModel.handleTapOnRunaway()
                        }
                case .tapRhythm:
                    Circle()
                        .fill(gameModel.rhythmActive ? Color.red : Color.gray)
                        .frame(width: 70, height: 70)
                        .shadow(radius: 5)
                        .onTapGesture {
                            gameModel.handleTapOnRhythm()
                        }
                        .overlay(
                            Text("Tap in rhythm!")
                                .foregroundColor(.white)
                                .font(.caption)
                                .bold()
                                .padding(.top, 60)
                        )
                case .tapWait:
                    if gameModel.waitVisible {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 70, height: 70)
                            .shadow(radius: 5)
                            .onTapGesture {
                                gameModel.handleTapOnWait()
                            }
                    }
                case .tapMulti:
                    HStack(spacing: 30) {
                        ForEach(0..<3, id: \.self) { idx in
                            Circle()
                                .fill(gameModel.multiActive[idx] ? Color.pink : Color.gray)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 5)
                                .onTapGesture {
                                    gameModel.handleTapOnMulti(index: idx)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .tapSwipe:
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 70, height: 70)
                        .shadow(radius: 5)
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { _ in
                                    gameModel.handleSwipeOnBall()
                                }
                        )
                        .overlay(
                            Text("Swipe me!")
                                .foregroundColor(.white)
                                .font(.caption)
                                .bold()
                                .padding(.top, 60)
                        )
                case .tapTilt:
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 70, height: 70)
                        .shadow(radius: 5)
                        .position(gameModel.tiltPosition)
                        .overlay(
                            Text("Tilt phone!")
                                .foregroundColor(.white)
                                .font(.caption)
                                .bold()
                                .padding(.top, 60)
                        )
                case .tapPinch:
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 70 * gameModel.pinchScale, height: 70 * gameModel.pinchScale)
                        .shadow(radius: 5)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { scale in
                                    gameModel.handlePinch(scale: scale)
                                }
                        )
                        .overlay(
                            Text("Pinch me!")
                                .foregroundColor(.white)
                                .font(.caption)
                                .bold()
                                .padding(.top, 60)
                        )
                case .superMix:
                    
                    Button(action: { gameModel.handleTapOnSuperMix() }) {
                        Text("Tap for random challenge!")
                            .font(.title2)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                default:
                    Circle()
                        .fill(Color.red)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 5)
                        .scaleEffect(gameModel.targetScale)
                        .position(gameModel.targetPosition)
                        .onTapGesture {
                            gameModel.handleTargetTap()
                        }
                }
            }
            
            if gameModel.isGameActive && !gameModel.isPaused {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { gameModel.pauseGame() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.18))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "pause.fill")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                            }
                        }
                        .padding(.bottom, 90)
                        .padding(.trailing, 22)
                        .shadow(radius: 4)
                    }
                }
                .allowsHitTesting(true)
            }
            
            if gameModel.isPaused && gameModel.isGameActive {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                VStack(spacing: 30) {
                    Text("Paused")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    if gameModel.score == 0 && gameModel.timeRemaining == gameModel.currentLevel?.timeLimit {
                        Button(action: { gameModel.resumeGame() }) {
                            Text("Start Game")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 180)
                                .background(Color.green)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                    } else {
                        Button(action: { gameModel.resumeGame() }) {
                            Text("Resume")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 180)
                                .background(Color.blue)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                    }
                }
            }
        }
        .onAppear {
            autoStartGameIfNeeded()
        }
        .sheet(isPresented: .constant(!hasSeenOnboarding)) {
            OnboardingView()
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(GameModel())
            .environmentObject(LevelManager())
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
} 
