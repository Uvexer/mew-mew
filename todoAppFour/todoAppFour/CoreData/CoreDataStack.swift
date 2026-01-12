import CoreData
import os.log

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "todoAppFour", category: "CoreData")
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoApp")
        
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                self?.logger.error("Failed to load Core Data stack: \(error.localizedDescription)")
            } else {
                self?.logger.info("Core Data stack loaded successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    @MainActor
    func save() async throws {
        let context = viewContext
        
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
            logger.info("Context saved successfully")
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
            throw error
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}

