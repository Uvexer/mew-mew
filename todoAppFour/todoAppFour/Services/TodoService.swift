import CoreData
import os.log

final class TodoService {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "todoAppFour", category: "TodoService")
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func fetchAll() async throws -> [TodoItem] {
        let request = TodoItemEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TodoItemEntity.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \TodoItemEntity.createdAt, ascending: false)
        ]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                entity.toModel()
            }
        } catch {
            logger.error("Failed to fetch todos: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func create(_ todo: TodoItem) async throws {
        let entity = TodoItemEntity(context: context)
        entity.id = todo.id
        entity.title = todo.title
        entity.notes = todo.notes
        entity.isCompleted = todo.isCompleted
        entity.priority = todo.priority.rawValue
        entity.createdAt = todo.createdAt
        entity.completedAt = todo.completedAt
        entity.dueDate = todo.dueDate
        
        if let categoryId = todo.categoryId {
            entity.category = try fetchCategoryEntity(by: categoryId)
        }
        
        try await CoreDataStack.shared.save()
        logger.info("Todo created: \(todo.title)")
    }
    
    @MainActor
    func update(_ todo: TodoItem) async throws {
        let request = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", todo.id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Todo not found for update: \(todo.id)")
            return
        }
        
        entity.title = todo.title
        entity.notes = todo.notes
        entity.isCompleted = todo.isCompleted
        entity.priority = todo.priority.rawValue
        entity.completedAt = todo.completedAt
        entity.dueDate = todo.dueDate
        
        if let categoryId = todo.categoryId {
            entity.category = try fetchCategoryEntity(by: categoryId)
        } else {
            entity.category = nil
        }
        
        try await CoreDataStack.shared.save()
        logger.info("Todo updated: \(todo.title)")
    }
    
    @MainActor
    func delete(_ id: UUID) async throws {
        let request = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Todo not found for deletion: \(id)")
            return
        }
        
        context.delete(entity)
        try await CoreDataStack.shared.save()
        logger.info("Todo deleted: \(id)")
    }
    
    @MainActor
    func toggleCompletion(_ id: UUID) async throws {
        let request = TodoItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Todo not found for toggle: \(id)")
            return
        }
        
        entity.isCompleted.toggle()
        entity.completedAt = entity.isCompleted ? Date() : nil
        
        try await CoreDataStack.shared.save()
        logger.info("Todo completion toggled: \(id)")
    }
    
    private func fetchCategoryEntity(by id: UUID) throws -> CategoryEntity? {
        let request = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try context.fetch(request).first
    }
}

extension TodoItemEntity {
    func toModel() -> TodoItem? {
        guard let id = id,
              let title = title,
              let createdAt = createdAt else {
            return nil
        }
        
        return TodoItem(
            id: id,
            title: title,
            notes: notes,
            isCompleted: isCompleted,
            priority: TodoPriority(rawValue: priority) ?? .medium,
            createdAt: createdAt,
            completedAt: completedAt,
            dueDate: dueDate,
            categoryId: category?.id
        )
    }
}

