import CoreData
import os.log

final class CategoryService {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "todoAppFour", category: "CategoryService")
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func fetchAll() async throws -> [Category] {
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.createdAt, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                entity.toModel()
            }
        } catch {
            logger.error("Failed to fetch categories: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func create(_ category: Category) async throws {
        let entity = CategoryEntity(context: context)
        entity.id = category.id
        entity.name = category.name
        entity.colorHex = category.colorHex
        entity.icon = category.icon
        entity.createdAt = category.createdAt
        
        try await CoreDataStack.shared.save()
        logger.info("Category created: \(category.name)")
    }
    
    @MainActor
    func update(_ category: Category) async throws {
        let request = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Category not found for update: \(category.id)")
            return
        }
        
        entity.name = category.name
        entity.colorHex = category.colorHex
        entity.icon = category.icon
        
        try await CoreDataStack.shared.save()
        logger.info("Category updated: \(category.name)")
    }
    
    @MainActor
    func delete(_ id: UUID) async throws {
        let request = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Category not found for deletion: \(id)")
            return
        }
        
        context.delete(entity)
        try await CoreDataStack.shared.save()
        logger.info("Category deleted: \(id)")
    }
    
    @MainActor
    func initializeDefaultCategories() async throws {
        let existing = try await fetchAll()
        guard existing.isEmpty else { return }
        
        let defaultCategories = [
            Category(name: "Work", colorHex: "3B82F6", icon: "briefcase.fill"),
            Category(name: "Personal", colorHex: "10B981", icon: "person.fill"),
            Category(name: "Shopping", colorHex: "F59E0B", icon: "cart.fill"),
            Category(name: "Health", colorHex: "EF4444", icon: "heart.fill")
        ]
        
        for category in defaultCategories {
            try await create(category)
        }
        
        logger.info("Default categories initialized")
    }
}

extension CategoryEntity {
    func toModel() -> Category? {
        guard let id = id,
              let name = name,
              let colorHex = colorHex,
              let createdAt = createdAt else {
            return nil
        }
        
        return Category(
            id: id,
            name: name,
            colorHex: colorHex,
            icon: icon ?? "folder.fill",
            createdAt: createdAt
        )
    }
}

