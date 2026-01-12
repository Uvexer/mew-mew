import Foundation

struct GameStats: Equatable {
    let id: UUID
    var totalPoints: Int
    var completedTasksCount: Int
    var currentStreak: Int
    var bestStreak: Int
    var lastCompletionDate: Date?
    var level: Int
    
    init(
        id: UUID = UUID(),
        totalPoints: Int = 0,
        completedTasksCount: Int = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        lastCompletionDate: Date? = nil,
        level: Int = 1
    ) {
        self.id = id
        self.totalPoints = totalPoints
        self.completedTasksCount = completedTasksCount
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.lastCompletionDate = lastCompletionDate
        self.level = level
    }
    
    var pointsToNextLevel: Int {
        level * 100
    }
    
    var progressToNextLevel: Double {
        let pointsInCurrentLevel = totalPoints % pointsToNextLevel
        return Double(pointsInCurrentLevel) / Double(pointsToNextLevel)
    }
}

