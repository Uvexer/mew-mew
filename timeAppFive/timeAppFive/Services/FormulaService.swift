import Foundation
import CoreData
import OSLog

protocol FormulaServiceProtocol {
    func fetchFormulas(for categoryId: UUID) async throws -> [FormulaModel]
    func createFormula(name: String, formulaText: String, description: String, variables: [String], categoryId: UUID) async throws -> FormulaModel
    func updateFormula(_ formula: FormulaModel) async throws
    func deleteFormula(_ formulaId: UUID) async throws
    func toggleLearnedStatus(formulaId: UUID) async throws
    func updateLastViewed(formulaId: UUID) async throws
    func searchFormulas(query: String) async throws -> [FormulaModel]
}

final class FormulaService: FormulaServiceProtocol {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "timeAppFive", category: "FormulaService")
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func fetchFormulas(for categoryId: UUID) async throws -> [FormulaModel] {
        let request = FormulaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category.id == %@", categoryId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FormulaEntity.orderIndex, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            logger.info("Fetched \(entities.count) formulas for category")
            return entities.map { FormulaModel(from: $0) }
        } catch {
            logger.error("Failed to fetch formulas: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func createFormula(name: String, formulaText: String, description: String, variables: [String], categoryId: UUID) async throws -> FormulaModel {
        let categoryRequest = CategoryEntity.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
        
        guard let category = try context.fetch(categoryRequest).first else {
            logger.error("Category not found")
            throw NSError(domain: "FormulaService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
        }
        
        let entity = FormulaEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.formulaText = formulaText
        entity.descriptionText = description
        entity.variables = variables.joined(separator: ",")
        entity.isLearned = false
        entity.orderIndex = Int16(try await fetchMaxOrderIndex(for: categoryId) + 1)
        entity.createdAt = Date()
        entity.category = category
        
        try context.save()
        logger.info("Created formula: \(name)")
        
        return FormulaModel(from: entity)
    }
    
    @MainActor
    func updateFormula(_ formula: FormulaModel) async throws {
        let request = FormulaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", formula.id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Formula not found for update")
            return
        }
        
        entity.name = formula.name
        entity.formulaText = formula.formulaText
        entity.descriptionText = formula.descriptionText
        entity.variables = formula.variables.joined(separator: ",")
        entity.isLearned = formula.isLearned
        entity.orderIndex = Int16(formula.orderIndex)
        
        try context.save()
        logger.info("Updated formula: \(formula.name)")
    }
    
    @MainActor
    func deleteFormula(_ formulaId: UUID) async throws {
        let request = FormulaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", formulaId as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Formula not found for deletion")
            return
        }
        
        context.delete(entity)
        try context.save()
        logger.info("Deleted formula")
    }
    
    @MainActor
    func toggleLearnedStatus(formulaId: UUID) async throws {
        let request = FormulaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", formulaId as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Formula not found for toggle")
            return
        }
        
        entity.isLearned.toggle()
        try context.save()
        logger.info("Toggled learned status for formula")
    }
    
    @MainActor
    func updateLastViewed(formulaId: UUID) async throws {
        let request = FormulaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", formulaId as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            logger.error("Formula not found for last viewed update")
            return
        }
        
        entity.lastViewedAt = Date()
        try context.save()
    }
    
    @MainActor
    func searchFormulas(query: String) async throws -> [FormulaModel] {
        guard !query.isEmpty else {
            return []
        }
        
        let request = FormulaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR formulaText CONTAINS[cd] %@ OR descriptionText CONTAINS[cd] %@", query, query, query)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FormulaEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            logger.info("Search found \(entities.count) formulas")
            return entities.map { FormulaModel(from: $0) }
        } catch {
            logger.error("Failed to search formulas: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    private func fetchMaxOrderIndex(for categoryId: UUID) async throws -> Int {
        let request = FormulaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category.id == %@", categoryId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FormulaEntity.orderIndex, ascending: false)]
        request.fetchLimit = 1
        
        guard let entity = try context.fetch(request).first else {
            return 0
        }
        
        return Int(entity.orderIndex)
    }
}

