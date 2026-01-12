import CoreData
import OSLog

final class GameService {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AnimalApp", category: "Game")
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveGameScore(correctAnswers: Int, totalQuestions: Int) {
        let entity = GameScoreEntity(context: context)
        entity.id = UUID()
        entity.correctAnswers = Int16(correctAnswers)
        entity.totalQuestions = Int16(totalQuestions)
        entity.date = Date()
        
        updateUserProgress(correctAnswers: correctAnswers, totalQuestions: totalQuestions)
        
        do {
            try context.save()
            logger.info("Game score saved: \(correctAnswers)/\(totalQuestions)")
        } catch {
            logger.error("Failed to save game score: \(error.localizedDescription)")
        }
    }
    
    func fetchRecentScores(limit: Int = 10) -> [GameScore] {
        let fetchRequest: NSFetchRequest<GameScoreEntity> = GameScoreEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GameScoreEntity.date, ascending: false)]
        fetchRequest.fetchLimit = limit
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { GameScore(from: $0) }
        } catch {
            logger.error("Failed to fetch game scores: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchUserProgress() -> UserProgress {
        let fetchRequest: NSFetchRequest<UserProgressEntity> = UserProgressEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                return UserProgress(from: entity)
            } else {
                return createInitialUserProgress()
            }
        } catch {
            logger.error("Failed to fetch user progress: \(error.localizedDescription)")
            return createInitialUserProgress()
        }
    }
    
    private func createInitialUserProgress() -> UserProgress {
        let entity = UserProgressEntity(context: context)
        entity.id = UUID()
        entity.gamesPlayed = 0
        entity.totalCorrectAnswers = 0
        entity.totalQuestions = 0
        
        do {
            try context.save()
            return UserProgress(from: entity)
        } catch {
            logger.error("Failed to create initial user progress: \(error.localizedDescription)")
            return UserProgress(id: UUID(), gamesPlayed: 0, totalCorrectAnswers: 0, totalQuestions: 0)
        }
    }
    
    private func updateUserProgress(correctAnswers: Int, totalQuestions: Int) {
        let fetchRequest: NSFetchRequest<UserProgressEntity> = UserProgressEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let entity: UserProgressEntity
            if let existing = try context.fetch(fetchRequest).first {
                entity = existing
            } else {
                entity = UserProgressEntity(context: context)
                entity.id = UUID()
                entity.gamesPlayed = 0
                entity.totalCorrectAnswers = 0
                entity.totalQuestions = 0
            }
            
            entity.gamesPlayed += 1
            entity.totalCorrectAnswers += Int32(correctAnswers)
            entity.totalQuestions += Int32(totalQuestions)
            
        } catch {
            logger.error("Failed to update user progress: \(error.localizedDescription)")
        }
    }
}

