import CoreData
import OSLog

final class PersistenceController {
    let container: NSPersistentContainer
    private let logger = Logger(subsystem: "com.planeapp", category: "persistence")
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PlaneAppModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                self?.logger.error("Failed to load Core Data: \(error.localizedDescription)")
            } else {
                self?.logger.info("Core Data loaded successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                logger.info("Context saved successfully")
            } catch {
                logger.error("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
}

