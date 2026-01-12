import Foundation

struct Project: Identifiable, Hashable {
    let id: UUID
    let name: String
    let colorHex: String
    let createdAt: Date
    
    init(from entity: ProjectEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.colorHex = entity.colorHex ?? "#007AFF"
        self.createdAt = entity.createdAt ?? Date()
    }
}

struct TimeEntry: Identifiable, Hashable {
    let id: UUID
    let startDate: Date
    let endDate: Date?
    let notes: String?
    let projectId: UUID
    let projectName: String
    let projectColorHex: String
    
    var duration: TimeInterval {
        let end = endDate ?? Date()
        return end.timeIntervalSince(startDate)
    }
    
    var isActive: Bool {
        endDate == nil
    }
    
    init(from entity: TimeEntryEntity) {
        self.id = entity.id ?? UUID()
        self.startDate = entity.startDate ?? Date()
        self.endDate = entity.endDate
        self.notes = entity.notes
        self.projectId = entity.project?.id ?? UUID()
        self.projectName = entity.project?.name ?? ""
        self.projectColorHex = entity.project?.colorHex ?? "#007AFF"
    }
}

struct ProjectStatistics {
    let project: Project
    let totalDuration: TimeInterval
    let entriesCount: Int
}

