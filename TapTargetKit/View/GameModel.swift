import SwiftUI
import Combine

class GameModel: ObservableObject {
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 30
    @Published var isGameActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var targetPosition: CGPoint = .zero
    @Published var targetScale: CGFloat = 1.0
    @Published var currentLevel: Level?
    @Published var currentNumber: Int = 1
    @Published var sequence: [Int] = []
    @Published var currentSequenceIndex: Int = 0
    @Published var lastTapTime: Date?
    @Published var isDoubleTapMode: Bool = false
    // For color ball levels
    @Published var colorChoices: [Color] = [.red, .green, .blue]
    @Published var targetColor: Color = .red
    // For moving target
    @Published var movingTargetOffset: CGSize = .zero
    @Published var isTargetVisible: Bool = true
    @Published var avoidColor: Color? = nil
    @Published var sequenceNumbers: [Int] = []
    @Published var isHolding: Bool = false
    @Published var holdStartTime: Date? = nil
    @Published var blinkVisible: Bool = true
    @Published var blinkTimer: AnyCancellable? = nil
    @Published var ballSizes: [CGFloat] = [30, 60, 90]
    @Published var changingColor: Color = .gray
    @Published var shapeToTap: String? = nil
    @Published var flashVisible: Bool = true
    @Published var flashTimer: AnyCancellable? = nil
    @Published var runawayPosition: CGPoint = CGPoint(x: 180, y: 400)
    @Published var rhythmActive: Bool = false
    @Published var waitVisible: Bool = false
    @Published var multiActive: [Bool] = [true, true, true]
    @Published var swipeActive: Bool = true
    @Published var tiltPosition: CGPoint = CGPoint(x: 180, y: 400)
    @Published var pinchScale: CGFloat = 1.0
    @Published var superMixType: LevelType = .tapStatic
    
    private var timer: AnyCancellable?
    private var movingTimer: AnyCancellable?
    private var disappearingTimer: AnyCancellable?
    private var runawayTimer: AnyCancellable?
    private let soundManager = SoundManager()
    
    func startGame(level: Level, pauseOnStart: Bool = true) {
        currentLevel = level
        score = 0
        timeRemaining = level.timeLimit
        isGameActive = true
        isPaused = pauseOnStart
        currentNumber = 1
        sequence = []
        currentSequenceIndex = 0
        lastTapTime = nil
        isDoubleTapMode = false
        movingTargetOffset = .zero
        isTargetVisible = true
        avoidColor = level.colorToAvoid
        sequenceNumbers = level.sequence ?? []
        currentSequenceIndex = 0
        isHolding = false
        holdStartTime = nil
        blinkVisible = true
        blinkTimer?.cancel()
        ballSizes = [30, 60, 90]
        changingColor = .gray
        shapeToTap = level.shapeToTap
        flashVisible = true
        flashTimer?.cancel()
        runawayPosition = CGPoint(x: 180, y: 400)
        rhythmActive = false
        waitVisible = false
        multiActive = [true, true, true]
        swipeActive = true
        tiltPosition = CGPoint(x: 180, y: 400)
        pinchScale = 1.0
        superMixType = LevelType.allCases.filter { $0 != LevelType.superMix }.randomElement() ?? .tapStatic
        
        if level.type == .tapMoving {
            startMovingTarget()
        }
        if level.type == .tapDisappearing {
            startDisappearingTarget(interval: level.blinkInterval ?? 0.7)
        }
        if level.type == .tapColor {
            colorChoices = [.red, .green, .blue, .yellow]
            targetColor = level.colorToTap ?? .yellow
        }
        if level.type == .tapAvoidColor {
            colorChoices = [.red, .green, .blue, .black]
            targetColor = colorChoices.randomElement() ?? .red
        }
        if level.type == .tapStatic {
            colorChoices = [.red]
            targetColor = .red
        }
        if level.type == .tapBlink {
            startBlinking(interval: level.blinkInterval ?? 0.4)
        }
        if level.type == .tapChangingColor {
            startChangingColor()
        }
        if level.type == .tapFlash {
            startFlash(interval: level.blinkInterval ?? 0.2)
        }
        if level.type == .tapRunaway {
            startRunawayBall()
        }
        if level.type == .tapRhythm {
            startRhythm()
        }
        if level.type == .tapWait {
            startWait()
        }
        if level.type == .superMix {
            superMixType = LevelType.allCases.filter { $0 != LevelType.superMix }.randomElement() ?? .tapStatic
        }
        if level.type == .tapBiggest {
            colorChoices = [.red, .green, .blue]
            targetColor = .red
        }
        
        moveTargetToRandomPosition()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    func pauseGame() {
        isPaused = true
    }
    
    func resumeGame() {
        isPaused = false
    }
    
    func endGame() {
        isGameActive = false
        timer?.cancel()
        movingTimer?.cancel()
        disappearingTimer?.cancel()
        runawayTimer?.cancel()
    }
    
    private func updateTimer() {
        if isPaused { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            endGame()
        }
    }
    
    func moveTargetToRandomPosition() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            targetPosition = CGPoint(
                x: CGFloat.random(in: 60...320),
                y: CGFloat.random(in: 120...650)
            )
        }
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            targetScale = 1.1
        }
    }
    
    private func startMovingTarget() {
        movingTimer?.cancel()
        movingTimer = Timer.publish(every: 0.7, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isGameActive, !self.isPaused else { return }
                self.moveTargetToRandomPosition()
            }
    }
    
    private func startDisappearingTarget(interval: Double) {
        disappearingTimer?.cancel()
        isTargetVisible = true
        disappearingTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isGameActive, !self.isPaused else { return }
                self.isTargetVisible.toggle()
            }
    }
    
    private func startRunawayBall() {
        runawayTimer?.cancel()
        runawayTimer = Timer.publish(every: 1.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isGameActive, !self.isPaused else { return }
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.runawayPosition = CGPoint(
                        x: CGFloat.random(in: 100...280),
                        y: CGFloat.random(in: 200...500)
                    )
                }
            }
    }
    
    func handleTapOnTarget(color: Color? = nil) {
        guard isGameActive, !isPaused, let level = currentLevel else { return }
        switch level.type {
        case .tapStatic:
            if color == nil || color == .red {
                handleSuccessTap()
            }
        case .tapMoving:
            if color == nil || color == .blue {
                handleSuccessTap()
            }
        case .tapDisappearing:
            if isTargetVisible && (color == nil || color == .green) {
                handleSuccessTap()
            }
        case .tapColor:
            if color == level.colorToTap {
                handleSuccessTap()
            }
        case .tapAvoidColor:
            if color != level.colorToAvoid {
                handleSuccessTap()
            } else {
                score = 0
            }
        case .tapSequence:
            handleTapOnSequence(number: currentSequenceIndex)
        case .tapPair:
            handleTapOnPair(selected: [currentSequenceIndex])
        case .tapHold:
            handleHoldTapBegan()
        case .tapBlink:
            handleTapOnBlink()
        case .tapSmallest:
            handleTapOnSmallest(index: currentSequenceIndex)
        case .tapBiggest:
            handleTapOnBiggest(index: currentSequenceIndex)
        case .tapChangingColor:
            handleTapOnChangingColor()
        case .tapShape:
            handleTapOnShape(shape: shapeToTap ?? "triangle")
        case .tapFlash:
            handleTapOnFlash()
        case .tapRunaway:
            handleTapOnRunaway()
        case .tapRhythm:
            handleTapOnRhythm()
        case .tapWait:
            handleTapOnWait()
        case .tapMulti:
            handleTapOnMulti(index: 0)
        case .tapSwipe:
            handleSwipeOnBall()
        case .tapTilt:
            handleTiltMove(x: 5, y: 5)
        case .tapPinch:
            handlePinch(scale: 2.0)
        case .superMix:
            handleTapOnSuperMix()
        }
    }
    
    private func handleSuccessTap() {
        soundManager.playBubbleSound()
        score += 1
        moveTargetToRandomPosition()
        if let level = currentLevel, score >= level.requiredTaps {
            endGame()
        }
    }
    
    func handleColorBallTap(color: Color) {
        guard isGameActive, !isPaused, let level = currentLevel, level.id >= 11 else { return }
        if color == targetColor {
            soundManager.playBubbleSound()
            score += 1
            targetColor = colorChoices.randomElement() ?? .red
        }
    }
    
    func handleTargetTap() {
        guard isGameActive, !isPaused, let level = currentLevel else { return }
        
        if level.id >= 11 {
            return
        }
        
        switch level.type {
        case .tapStatic:
            handleTapOnTarget()
        case .tapMoving:
            handleTapOnTarget()
        case .tapDisappearing:
            handleTapOnTarget()
        case .tapColor:
            handleTapOnTarget()
        case .tapAvoidColor:
            handleTapOnTarget()
        case .tapSequence:
            handleTapOnSequence(number: currentSequenceIndex)
        case .tapPair:
            handleTapOnPair(selected: [currentSequenceIndex])
        case .tapHold:
            handleHoldTapBegan()
        case .tapBlink:
            handleTapOnBlink()
        case .tapSmallest:
            handleTapOnSmallest(index: currentSequenceIndex)
        case .tapBiggest:
            handleTapOnBiggest(index: currentSequenceIndex)
        case .tapChangingColor:
            handleTapOnChangingColor()
        case .tapShape:
            handleTapOnShape(shape: shapeToTap ?? "triangle")
        case .tapFlash:
            handleTapOnFlash()
        case .tapRunaway:
            handleTapOnRunaway()
        case .tapRhythm:
            handleTapOnRhythm()
        case .tapWait:
            handleTapOnWait()
        case .tapMulti:
            handleTapOnMulti(index: 0)
        case .tapSwipe:
            handleSwipeOnBall()
        case .tapTilt:
            handleTiltMove(x: 5, y: 5)
        case .tapPinch:
            handlePinch(scale: 2.0)
        case .superMix:
            handleTapOnSuperMix()
        }
    }
    
    private func handleSequenceTap() {
        soundManager.playBubbleSound()
        if currentSequenceIndex < sequence.count {
            score += 1
            currentSequenceIndex += 1
            moveTargetToRandomPosition()
            
            if currentSequenceIndex >= sequence.count {
                endGame()
            }
        }
    }
    
    private func startBlinking(interval: Double) {
        blinkTimer?.cancel()
        blinkVisible = true
        blinkTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isGameActive, !self.isPaused else { return }
                self.blinkVisible.toggle()
            }
    }
    
    func handleTapOnSequence(number: Int) {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapSequence else { return }
        if sequenceNumbers.indices.contains(currentSequenceIndex), sequenceNumbers[currentSequenceIndex] == number {
            currentSequenceIndex += 1
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        } else {
            score = 0
            currentSequenceIndex = 0
        }
    }
    
    func handleTapOnPair(selected: [Int]) {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapPair else { return }
        if selected.count == 2 {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    
    func handleHoldTapBegan() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapHold else { return }
        isHolding = true
        holdStartTime = Date()
    }
    func handleHoldTapEnded() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapHold else { return }
        isHolding = false
        if let start = holdStartTime, Date().timeIntervalSince(start) >= (level.holdDuration ?? 1.0) {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
        holdStartTime = nil
    }
    
    func handleTapOnBlink() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapBlink else { return }
        if blinkVisible {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    
    func handleTapOnSmallest(index: Int) {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapSmallest else { return }
        if index == 0 {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    func handleTapOnBiggest(index: Int) {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapBiggest else { return }
        if index == ballSizes.count - 1 {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    
    private func startChangingColor() {
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive, !self.isPaused else { return }
            let colors: [Color] = [.pink, .gray, .yellow, .blue]
            self.changingColor = colors.randomElement() ?? .gray
        }
    }
    private func startFlash(interval: Double) {
        flashTimer?.cancel()
        flashVisible = true
        flashTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isGameActive, !self.isPaused else { return }
                self.flashVisible.toggle()
            }
    }
    func handleTapOnChangingColor() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapChangingColor else { return }
        if changingColor == (level.colorToTap ?? .pink) {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    func handleTapOnShape(shape: String) {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapShape else { return }
        if shape == (level.shapeToTap ?? "triangle") {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    func handleTapOnFlash() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapFlash else { return }
        if flashVisible {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    func handleTapOnRunaway() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapRunaway else { return }
        score += 1
        soundManager.playBubbleSound()
        runawayPosition = CGPoint(x: CGFloat.random(in: 60...320), y: CGFloat.random(in: 120...650))
        if score >= level.requiredTaps {
            endGame()
        }
    }
    private func startRhythm() {
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive, !self.isPaused else { return }
            self.rhythmActive.toggle()
        }
    }
    func handleTapOnRhythm() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapRhythm else { return }
        if rhythmActive {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    private func startWait() {
        waitVisible = false
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.waitVisible = true
        }
    }
    func handleTapOnWait() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapWait else { return }
        if waitVisible {
            score += 1
            soundManager.playBubbleSound()
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    func handleTapOnMulti(index: Int) {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapMulti else { return }
        multiActive[index] = false
        if multiActive.allSatisfy({ !$0 }) {
            score += 1
            soundManager.playBubbleSound()
            multiActive = [true, true, true]
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    func handleSwipeOnBall() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapSwipe else { return }
        score += 1
        soundManager.playBubbleSound()
        if score >= level.requiredTaps {
            endGame()
        }
    }
    func handleTiltMove(x: CGFloat, y: CGFloat) {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapTilt else { return }
        tiltPosition = CGPoint(x: tiltPosition.x + x, y: tiltPosition.y + y)
    }
    func handlePinch(scale: CGFloat) {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .tapPinch else { return }
        pinchScale = scale
        if pinchScale > 1.5 || pinchScale < 0.7 {
            score += 1
            soundManager.playBubbleSound()
            pinchScale = 1.0
            if score >= level.requiredTaps {
                endGame()
            }
        }
    }
    func handleTapOnSuperMix() {
        guard isGameActive, !isPaused, let level = currentLevel, level.type == .superMix else { return }
        switch superMixType {
        case .tapStatic: handleTapOnTarget()
        case .tapMoving: handleTapOnTarget()
        case .tapDisappearing: handleTapOnTarget()
        case .tapColor: handleTapOnTarget()
        case .tapAvoidColor: handleTapOnTarget()
        case .tapSequence: handleTapOnSequence(number: 1)
        case .tapPair: handleTapOnPair(selected: [0,1])
        case .tapHold: handleHoldTapBegan(); handleHoldTapEnded()
        case .tapBlink: handleTapOnBlink()
        case .tapSmallest: handleTapOnSmallest(index: 0)
        case .tapBiggest: handleTapOnBiggest(index: 2)
        case .tapChangingColor: handleTapOnChangingColor()
        case .tapShape: handleTapOnShape(shape: shapeToTap ?? "triangle")
        case .tapFlash: handleTapOnFlash()
        case .tapRunaway: handleTapOnRunaway()
        case .tapRhythm: handleTapOnRhythm()
        case .tapWait: handleTapOnWait()
        case .tapMulti: handleTapOnMulti(index: 0)
        case .tapSwipe: handleSwipeOnBall()
        case .tapTilt: handleTiltMove(x: 5, y: 5)
        case .tapPinch: handlePinch(scale: 2.0)
        case .superMix: break
        }
    }
    
    func nextLevel(levelManager: LevelManager) {
        guard let current = currentLevel,
              let next = levelManager.levels.first(where: { $0.id == current.id + 1 }) else { return }
        
        levelManager.unlockNextLevel()
        startGame(level: next, pauseOnStart: false)
    }
    
    func retryLevel() {
        if let level = currentLevel {
            startGame(level: level, pauseOnStart: false)
        }
    }
} 
