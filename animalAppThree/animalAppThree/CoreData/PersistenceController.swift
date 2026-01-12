import CoreData
import OSLog

final class PersistenceController {
    static let shared = PersistenceController()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AnimalApp", category: "Persistence")
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AnimalAppThree")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                self?.logger.error("Failed to load Core Data stack: \(error.localizedDescription)")
                return
            }
            
            self?.logger.info("Core Data loaded successfully from: \(description.url?.absoluteString ?? "unknown")")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            logger.info("Context saved successfully")
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    func deleteAll<T: NSManagedObject>(_ type: T.Type) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
            save()
            logger.info("Deleted all entities of type: \(String(describing: T.self))")
        } catch {
            logger.error("Failed to delete entities: \(error.localizedDescription)")
        }
    }
}

