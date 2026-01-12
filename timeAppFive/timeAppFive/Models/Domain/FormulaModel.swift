import Foundation

struct FormulaModel: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let formulaText: String
    let descriptionText: String
    let variables: [String]
    let isLearned: Bool
    let orderIndex: Int
    let createdAt: Date
    let lastViewedAt: Date?
    let categoryId: UUID?
    
    init(
        id: UUID = UUID(),
        name: String,
        formulaText: String,
        descriptionText: String,
        variables: [String] = [],
        isLearned: Bool = false,
        orderIndex: Int = 0,
        createdAt: Date = Date(),
        lastViewedAt: Date? = nil,
        categoryId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.formulaText = formulaText
        self.descriptionText = descriptionText
        self.variables = variables
        self.isLearned = isLearned
        self.orderIndex = orderIndex
        self.createdAt = createdAt
        self.lastViewedAt = lastViewedAt
        self.categoryId = categoryId
    }
    
    init(from entity: FormulaEntity) {
        self.id = entity.id
        self.name = entity.name
        self.formulaText = entity.formulaText
        self.descriptionText = entity.descriptionText
        
        if let variablesString = entity.variables, !variablesString.isEmpty {
            self.variables = variablesString.components(separatedBy: ",")
        } else {
            self.variables = []
        }
        
        self.isLearned = entity.isLearned
        self.orderIndex = Int(entity.orderIndex)
        self.createdAt = entity.createdAt
        self.lastViewedAt = entity.lastViewedAt
        self.categoryId = entity.category?.id
    }
}

extension FormulaModel {
    func with(
        isLearned: Bool? = nil
    ) -> FormulaModel {
        FormulaModel(
            id: id,
            name: name,
            formulaText: formulaText,
            descriptionText: descriptionText,
            variables: variables,
            isLearned: isLearned ?? self.isLearned,
            orderIndex: orderIndex,
            createdAt: createdAt,
            lastViewedAt: self.lastViewedAt,
            categoryId: categoryId
        )
    }
}

