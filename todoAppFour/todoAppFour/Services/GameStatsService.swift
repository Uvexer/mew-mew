import CoreData
import os.log

final class GameStatsService {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "todoAppFour", category: "GameStatsService")
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func fetchStats() async throws -> GameStats {
        let request = GameStatsEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            
            if let entity = entities.first {
                return entity.toModel()
            } else {
                let newStats = GameStats()
                try await createStats(newStats)
                return newStats
            }
        } catch {
            logger.error("Failed to fetch game stats: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func updateStats(_ stats: GameStats) async throws {
        let request = GameStatsEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            let entity: GameStatsEntity
            
            if let existingEntity = entities.first {
                entity = existingEntity
            } else {
                entity = GameStatsEntity(context: context)
                entity.id = stats.id
            }
            
            entity.totalPoints = Int64(stats.totalPoints)
            entity.completedTasksCount = Int64(stats.completedTasksCount)
            entity.currentStreak = Int64(stats.currentStreak)
            entity.bestStreak = Int64(stats.bestStreak)
            entity.lastCompletionDate = stats.lastCompletionDate
            entity.level = Int64(stats.level)
            
            try await CoreDataStack.shared.save()
            logger.info("Game stats updated")
        } catch {
            logger.error("Failed to update game stats: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func addPoints(_ points: Int) async throws {
        var stats = try await fetchStats()
        stats.totalPoints += points
        stats.completedTasksCount += 1
        
        updateStreak(&stats)
        updateLevel(&stats)
        
        try await updateStats(stats)
        logger.info("Points added: \(points)")
    }
    
    private func updateStreak(_ stats: inout GameStats) {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastDate = stats.lastCompletionDate {
            let daysDifference = calendar.dateComponents([.day], from: lastDate, to: now).day ?? 0
            
            if daysDifference == 0 {
                return
            } else if daysDifference == 1 {
                stats.currentStreak += 1
            } else {
                stats.currentStreak = 1
            }
        } else {
            stats.currentStreak = 1
        }
        
        if stats.currentStreak > stats.bestStreak {
            stats.bestStreak = stats.currentStreak
        }
        
        stats.lastCompletionDate = now
    }
    
    private func updateLevel(_ stats: inout GameStats) {
        let newLevel = (stats.totalPoints / 100) + 1
        stats.level = max(newLevel, stats.level)
    }
    
    private func createStats(_ stats: GameStats) async throws {
        let entity = GameStatsEntity(context: context)
        entity.id = stats.id
        entity.totalPoints = Int64(stats.totalPoints)
        entity.completedTasksCount = Int64(stats.completedTasksCount)
        entity.currentStreak = Int64(stats.currentStreak)
        entity.bestStreak = Int64(stats.bestStreak)
        entity.lastCompletionDate = stats.lastCompletionDate
        entity.level = Int64(stats.level)
        
        try await CoreDataStack.shared.save()
        logger.info("Game stats created")
    }
}

extension GameStatsEntity {
    func toModel() -> GameStats {
        GameStats(
            id: id ?? UUID(),
            totalPoints: Int(totalPoints),
            completedTasksCount: Int(completedTasksCount),
            currentStreak: Int(currentStreak),
            bestStreak: Int(bestStreak),
            lastCompletionDate: lastCompletionDate,
            level: Int(level)
        )
    }
}

