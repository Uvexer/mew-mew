import Foundation
import CoreData
import OSLog

final class DataInitializationService {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "timeAppFive", category: "DataInitialization")
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func initializeDefaultData() async throws {
        let request = CategoryEntity.fetchRequest()
        let count = try context.count(for: request)
        
        guard count == 0 else {
            logger.info("Data already initialized")
            return
        }
        
        logger.info("Initializing default data")
        
        try await createMathCategory()
        try await createPhysicsCategory()
        try await createChemistryCategory()
        
        logger.info("Default data initialized successfully")
    }
    
    @MainActor
    private func createMathCategory() async throws {
        let category = CategoryEntity(context: context)
        category.id = UUID()
        category.name = "Математика"
        category.iconName = "function"
        category.colorHex = "FF6B6B"
        category.orderIndex = 0
        
        let formulas = [
            ("Теорема Пифагора", "a² + b² = c²", "Квадрат гипотенузы равен сумме квадратов катетов", "a,b,c"),
            ("Формула квадратного корня", "x = (-b ± √(b² - 4ac)) / 2a", "Решение квадратного уравнения ax² + bx + c = 0", "a,b,c,x"),
            ("Площадь круга", "S = πr²", "Площадь круга через радиус", "r,S"),
            ("Периметр прямоугольника", "P = 2(a + b)", "Периметр прямоугольника со сторонами a и b", "a,b,P"),
            ("Объем цилиндра", "V = πr²h", "Объем цилиндра через радиус основания и высоту", "r,h,V"),
        ]
        
        for (index, formula) in formulas.enumerated() {
            let entity = FormulaEntity(context: context)
            entity.id = UUID()
            entity.name = formula.0
            entity.formulaText = formula.1
            entity.descriptionText = formula.2
            entity.variables = formula.3
            entity.isLearned = false
            entity.orderIndex = Int16(index)
            entity.createdAt = Date()
            entity.category = category
        }
        
        try context.save()
    }
    
    @MainActor
    private func createPhysicsCategory() async throws {
        let category = CategoryEntity(context: context)
        category.id = UUID()
        category.name = "Физика"
        category.iconName = "atom"
        category.colorHex = "4ECDC4"
        category.orderIndex = 1
        
        let formulas = [
            ("Второй закон Ньютона", "F = ma", "Сила равна произведению массы на ускорение", "F,m,a"),
            ("Закон всемирного тяготения", "F = G(m₁m₂)/r²", "Сила притяжения между двумя телами", "F,G,m₁,m₂,r"),
            ("Кинетическая энергия", "E = mv²/2", "Энергия движущегося тела", "E,m,v"),
            ("Закон Ома", "I = U/R", "Сила тока в проводнике прямо пропорциональна напряжению", "I,U,R"),
            ("Мощность", "P = UI", "Мощность электрического тока", "P,U,I"),
        ]
        
        for (index, formula) in formulas.enumerated() {
            let entity = FormulaEntity(context: context)
            entity.id = UUID()
            entity.name = formula.0
            entity.formulaText = formula.1
            entity.descriptionText = formula.2
            entity.variables = formula.3
            entity.isLearned = false
            entity.orderIndex = Int16(index)
            entity.createdAt = Date()
            entity.category = category
        }
        
        try context.save()
    }
    
    @MainActor
    private func createChemistryCategory() async throws {
        let category = CategoryEntity(context: context)
        category.id = UUID()
        category.name = "Химия"
        category.iconName = "flask"
        category.colorHex = "95E1D3"
        category.orderIndex = 2
        
        let formulas = [
            ("Молярная масса", "M = m/n", "Масса одного моля вещества", "M,m,n"),
            ("Концентрация раствора", "C = n/V", "Молярная концентрация вещества в растворе", "C,n,V"),
            ("Закон Авогадро", "V = nVₘ", "Объем газа при нормальных условиях", "V,n,Vₘ"),
            ("Уравнение Менделеева-Клапейрона", "PV = nRT", "Уравнение состояния идеального газа", "P,V,n,R,T"),
            ("Массовая доля", "ω = m₁/m₂", "Отношение массы вещества к массе смеси", "ω,m₁,m₂"),
        ]
        
        for (index, formula) in formulas.enumerated() {
            let entity = FormulaEntity(context: context)
            entity.id = UUID()
            entity.name = formula.0
            entity.formulaText = formula.1
            entity.descriptionText = formula.2
            entity.variables = formula.3
            entity.isLearned = false
            entity.orderIndex = Int16(index)
            entity.createdAt = Date()
            entity.category = category
        }
        
        try context.save()
    }
}

