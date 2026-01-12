import Foundation
import CoreData
import OSLog

final class CoreDataService {
    static let shared = CoreDataService()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ballapp", category: "CoreData")
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BallAppModel")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                self.logger.error("Failed to load Core Data: \(error.localizedDescription)")
            } else {
                self.logger.info("Core Data loaded successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    @MainActor
    func saveContext() {
        let context = viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            logger.info("Context saved successfully")
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchGameSession() -> GameSessionEntity? {
        let request = GameSessionEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "lastPlayed", ascending: false)]
        
        do {
            let results = try viewContext.fetch(request)
            return results.first
        } catch {
            logger.error("Failed to fetch game session: \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    func createGameSession(
        bounces: Int32,
        gravity: Double,
        bounciness: Double,
        airResistance: Double,
        highScore: Int32
    ) -> GameSessionEntity {
        let session = GameSessionEntity(context: viewContext)
        session.id = UUID()
        session.bounces = bounces
        session.gravity = gravity
        session.bounciness = bounciness
        session.airResistance = airResistance
        session.highScore = highScore
        session.lastPlayed = Date()
        
        saveContext()
        logger.info("Created new game session")
        
        return session
    }
    
    @MainActor
    func updateGameSession(
        _ session: GameSessionEntity,
        bounces: Int32,
        gravity: Double,
        bounciness: Double,
        airResistance: Double,
        highScore: Int32
    ) {
        session.bounces = bounces
        session.gravity = gravity
        session.bounciness = bounciness
        session.airResistance = airResistance
        session.highScore = highScore
        session.lastPlayed = Date()
        
        saveContext()
        logger.info("Updated game session")
    }
}

