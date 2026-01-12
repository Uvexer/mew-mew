import Foundation

struct GameScore: Identifiable {
    let id: UUID
    let correctAnswers: Int
    let totalQuestions: Int
    let date: Date
    
    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    init(from entity: GameScoreEntity) {
        self.id = entity.id ?? UUID()
        self.correctAnswers = Int(entity.correctAnswers)
        self.totalQuestions = Int(entity.totalQuestions)
        self.date = entity.date ?? Date()
    }
}

struct UserProgress {
    let id: UUID
    let gamesPlayed: Int
    let totalCorrectAnswers: Int
    let totalQuestions: Int
    
    var averageScore: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestions) * 100
    }
    
    init(from entity: UserProgressEntity) {
        self.id = entity.id ?? UUID()
        self.gamesPlayed = Int(entity.gamesPlayed)
        self.totalCorrectAnswers = Int(entity.totalCorrectAnswers)
        self.totalQuestions = Int(entity.totalQuestions)
    }
    
    init(id: UUID, gamesPlayed: Int, totalCorrectAnswers: Int, totalQuestions: Int) {
        self.id = id
        self.gamesPlayed = gamesPlayed
        self.totalCorrectAnswers = totalCorrectAnswers
        self.totalQuestions = totalQuestions
    }
}

