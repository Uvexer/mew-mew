import Foundation

enum TodoPriority: Int16, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var points: Int {
        switch self {
        case .low: return 10
        case .medium: return 20
        case .high: return 30
        }
    }
}

struct TodoItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String?
    var isCompleted: Bool
    var priority: TodoPriority
    var createdAt: Date
    var completedAt: Date?
    var dueDate: Date?
    var categoryId: UUID?
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        isCompleted: Bool = false,
        priority: TodoPriority = .medium,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        dueDate: Date? = nil,
        categoryId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.dueDate = dueDate
        self.categoryId = categoryId
    }
}

