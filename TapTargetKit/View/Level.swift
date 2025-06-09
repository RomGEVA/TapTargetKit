import SwiftUI

enum LevelType: CaseIterable {
    case tapStatic
    case tapMoving
    case tapDisappearing
    case tapColor
    case tapAvoidColor
    case tapSequence
    case tapPair
    case tapHold
    case tapBlink
    case tapSmallest
    case tapBiggest
    case tapChangingColor
    case tapShape
    case tapFlash
    case tapRunaway
    case tapRhythm
    case tapWait
    case tapMulti
    case tapSwipe
    case tapTilt
    case tapPinch
    case superMix
}

struct Level: Identifiable {
    let id: Int
    let type: LevelType
    let requiredTaps: Int
    let timeLimit: Int
    let description: String
    let isUnlocked: Bool
    let colorToTap: Color?
    let colorToAvoid: Color?
    let shapeToTap: String?
    let sequence: [Int]?
    let holdDuration: Double?
    let blinkInterval: Double?
    let minTapCount: Int?
    let maxTapCount: Int?
    
    var title: String {
        "Level \(id)"
    }
}

class LevelManager: ObservableObject {
    @Published var levels: [Level] = []
    @Published var currentLevel: Level?
    private let unlockedLevelsKey = "unlockedLevels"
    private var unlockedLevels: Int {
        get { UserDefaults.standard.integer(forKey: unlockedLevelsKey) == 0 ? 1 : UserDefaults.standard.integer(forKey: unlockedLevelsKey) }
        set { UserDefaults.standard.set(newValue, forKey: unlockedLevelsKey) }
    }
    
    init() {
        createLevels()
    }
    
    private func createLevels() {
        let baseLevels = [
            Level(id: 1, type: .tapStatic, requiredTaps: 5, timeLimit: 30, description: "Tap the static red ball 5 times", isUnlocked: true, colorToTap: .red, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 2, type: .tapMoving, requiredTaps: 7, timeLimit: 25, description: "Tap the moving blue ball 7 times", isUnlocked: false, colorToTap: .blue, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 3, type: .tapDisappearing, requiredTaps: 8, timeLimit: 20, description: "Tap the ball before it disappears!", isUnlocked: false, colorToTap: .green, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: 0.7, minTapCount: nil, maxTapCount: nil),
            Level(id: 4, type: .tapFlash, requiredTaps: 8, timeLimit: 15, description: "Quick! Tap the flashing ball!", isUnlocked: false, colorToTap: .cyan, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: 0.2, minTapCount: nil, maxTapCount: nil),
            Level(id: 5, type: .tapRunaway, requiredTaps: 6, timeLimit: 30, description: "Catch the slow-moving ball!", isUnlocked: false, colorToTap: .mint, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 6, type: .tapRhythm, requiredTaps: 10, timeLimit: 15, description: "Tap to the beat!", isUnlocked: false, colorToTap: .red, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 7, type: .tapWait, requiredTaps: 6, timeLimit: 18, description: "Wait for the ball to appear!", isUnlocked: false, colorToTap: .blue, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 8, type: .tapMulti, requiredTaps: 8, timeLimit: 30, description: "Tap all three balls at once!", isUnlocked: false, colorToTap: nil, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: 3, maxTapCount: 3),
            Level(id: 9, type: .tapSwipe, requiredTaps: 8, timeLimit: 15, description: "Swipe the ball!", isUnlocked: false, colorToTap: .orange, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 10, type: .tapStatic, requiredTaps: 5, timeLimit: 20, description: "Tap the purple ball 5 times", isUnlocked: false, colorToTap: .purple, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 11, type: .tapStatic, requiredTaps: 5, timeLimit: 20, description: "Tap the yellow ball 5 times", isUnlocked: false, colorToTap: .yellow, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 12, type: .tapChangingColor, requiredTaps: 12, timeLimit: 15, description: "Tap the ball when it turns pink!", isUnlocked: false, colorToTap: .pink, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 13, type: .tapShape, requiredTaps: 8, timeLimit: 18, description: "Tap the triangle!", isUnlocked: false, colorToTap: nil, colorToAvoid: nil, shapeToTap: "triangle", sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 14, type: .tapBiggest, requiredTaps: 10, timeLimit: 15, description: "Tap the biggest ball!", isUnlocked: false, colorToTap: nil, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 15, type: .tapAvoidColor, requiredTaps: 12, timeLimit: 18, description: "Tap any ball except black!", isUnlocked: false, colorToTap: nil, colorToAvoid: .black, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 16, type: .tapSequence, requiredTaps: 5, timeLimit: 20, description: "Tap balls in order: 1-2-3-4-5", isUnlocked: false, colorToTap: nil, colorToAvoid: nil, shapeToTap: nil, sequence: [1,2,3,4,5], holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 17, type: .tapPair, requiredTaps: 6, timeLimit: 18, description: "Tap two balls at the same time!", isUnlocked: false, colorToTap: nil, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: 2, maxTapCount: 2),
            Level(id: 18, type: .tapHold, requiredTaps: 4, timeLimit: 20, description: "Hold the ball for 1 second!", isUnlocked: false, colorToTap: .purple, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: 1.0, blinkInterval: nil, minTapCount: nil, maxTapCount: nil),
            Level(id: 19, type: .tapBlink, requiredTaps: 8, timeLimit: 18, description: "Tap the blinking ball!", isUnlocked: false, colorToTap: .orange, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: 0.4, minTapCount: nil, maxTapCount: nil),
            Level(id: 20, type: .superMix, requiredTaps: 20, timeLimit: 20, description: "Ultimate challenge: all mechanics!", isUnlocked: false, colorToTap: nil, colorToAvoid: nil, shapeToTap: nil, sequence: nil, holdDuration: nil, blinkInterval: nil, minTapCount: nil, maxTapCount: nil)
        ]
        levels = baseLevels.enumerated().map { (index, level) in
            Level(
                id: level.id,
                type: level.type,
                requiredTaps: level.requiredTaps,
                timeLimit: level.timeLimit,
                description: level.description,
                isUnlocked: index < unlockedLevels,
                colorToTap: level.colorToTap,
                colorToAvoid: level.colorToAvoid,
                shapeToTap: level.shapeToTap,
                sequence: level.sequence,
                holdDuration: level.holdDuration,
                blinkInterval: level.blinkInterval,
                minTapCount: level.minTapCount,
                maxTapCount: level.maxTapCount
            )
        }
    }
    
    func unlockNextLevel() {
        if unlockedLevels < levels.count {
            unlockedLevels += 1
            createLevels()
        }
    }
    
    func selectLevel(_ level: Level) {
        currentLevel = level
    }
    
    func lastUnlockedLevel() -> Level? {
        levels.last(where: { $0.isUnlocked })
    }
    
    func resetProgress() {
        unlockedLevels = 1
        createLevels()
    }
} 
