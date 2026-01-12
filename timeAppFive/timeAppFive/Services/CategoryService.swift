import Foundation
import CoreData
import OSLog

protocol CategoryServiceProtocol {
    func fetchCategories() async throws -> [CategoryModel]
    func createCategory(name: String, iconName: String, colorHex: String) async throws -> CategoryModel
    func updateCategory(_ category: CategoryModel) async throws
    func deleteCategory(_ categoryId: UUID) async throws
}

final class CategoryService: CategoryServiceProtocol {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "timeAppFive", category: "CategoryService")
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func fetchCategories() async throws -> [CategoryModel] {
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.orderIndex, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            logger.info("Fetched \(entities.count) categories")
            return entities.map { CategoryModel(from: $0) }
        } catch {
            logger.error("Failed to fetch categories: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func createCategory(name: String, iconName: String, colorHex: String) async throws -> CategoryModel {
        let entity = CategoryEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.iconName = iconName
        entity.colorHex = colorHex
        entity.orderIndex = Int16(try await fetchMaxOrderIndex() + 1)
        
        try context.save()
        logger.info("Created category: \(name)")
        
        return CategoryModel(from: entity)
    }
    
    @MainActor
    func updateCategory(_ category: CategoryModel) async throws {
        let request = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Category not found for update")
            return
        }
        
        entity.name = category.name
        entity.iconName = category.iconName
        entity.colorHex = category.colorHex
        entity.orderIndex = Int16(category.orderIndex)
        
        try context.save()
        logger.info("Updated category: \(category.name)")
    }
    
    @MainActor
    func deleteCategory(_ categoryId: UUID) async throws {
        let request = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Category not found for deletion")
            return
        }
        
        context.delete(entity)
        try context.save()
        logger.info("Deleted category")
    }
    
    @MainActor
    private func fetchMaxOrderIndex() async throws -> Int {
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.orderIndex, ascending: false)]
        request.fetchLimit = 1
        
        guard let entity = try context.fetch(request).first else {
            return 0
        }
        
        return Int(entity.orderIndex)
    }
}

