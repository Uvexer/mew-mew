import Foundation
import CoreData
import OSLog

final class CoreDataService {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "workAppSix", category: "CoreData")
    
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: "TimeTracker")
        container.loadPersistentStores { description, error in
            if let error = error {
                self.logger.error("Failed to load Core Data stack: \(error.localizedDescription)")
            } else {
                self.logger.info("Core Data stack loaded successfully")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    @MainActor
    func save() async {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
            logger.info("Context saved successfully")
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createProject(name: String, colorHex: String) async -> ProjectEntity {
        let project = ProjectEntity(context: viewContext)
        project.id = UUID()
        project.name = name
        project.colorHex = colorHex
        project.createdAt = Date()
        
        await save()
        logger.info("Project created: \(name)")
        return project
    }
    
    @MainActor
    func updateProject(_ project: ProjectEntity, name: String, colorHex: String) async {
        project.name = name
        project.colorHex = colorHex
        await save()
        logger.info("Project updated: \(name)")
    }
    
    @MainActor
    func deleteProject(_ project: ProjectEntity) async {
        viewContext.delete(project)
        await save()
        logger.info("Project deleted")
    }
    
    @MainActor
    func startTimeEntry(for project: ProjectEntity, notes: String?) async -> TimeEntryEntity {
        let entry = TimeEntryEntity(context: viewContext)
        entry.id = UUID()
        entry.startDate = Date()
        entry.notes = notes
        entry.project = project
        
        await save()
        logger.info("Time entry started for project: \(project.name ?? "")")
        return entry
    }
    
    @MainActor
    func stopTimeEntry(_ entry: TimeEntryEntity) async {
        entry.endDate = Date()
        await save()
        logger.info("Time entry stopped")
    }
    
    @MainActor
    func updateTimeEntry(_ entry: TimeEntryEntity, startDate: Date, endDate: Date?, notes: String?) async {
        entry.startDate = startDate
        entry.endDate = endDate
        entry.notes = notes
        await save()
        logger.info("Time entry updated")
    }
    
    @MainActor
    func deleteTimeEntry(_ entry: TimeEntryEntity) async {
        viewContext.delete(entry)
        await save()
        logger.info("Time entry deleted")
    }
    
    func fetchProjects() -> [ProjectEntity] {
        let request: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProjectEntity.createdAt, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            logger.error("Failed to fetch projects: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchTimeEntries(for project: ProjectEntity? = nil, from startDate: Date? = nil, to endDate: Date? = nil) -> [TimeEntryEntity] {
        let request: NSFetchRequest<TimeEntryEntity> = TimeEntryEntity.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        if let project = project {
            predicates.append(NSPredicate(format: "project == %@", project))
        }
        
        if let startDate = startDate {
            predicates.append(NSPredicate(format: "startDate >= %@", startDate as NSDate))
        }
        
        if let endDate = endDate {
            predicates.append(NSPredicate(format: "startDate <= %@", endDate as NSDate))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TimeEntryEntity.startDate, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            logger.error("Failed to fetch time entries: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchActiveTimeEntry() -> TimeEntryEntity? {
        let request: NSFetchRequest<TimeEntryEntity> = TimeEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "endDate == nil")
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            logger.error("Failed to fetch active time entry: \(error.localizedDescription)")
            return nil
        }
    }
}

