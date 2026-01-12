import Foundation

struct Flight: Identifiable {
    let id: UUID
    let date: Date
    let score: Int
    let duration: Int
    let obstaclesAvoided: Int
    
    init(from entity: FlightEntity) {
        self.id = entity.id ?? UUID()
        self.date = entity.date ?? Date()
        self.score = Int(entity.score)
        self.duration = Int(entity.duration)
        self.obstaclesAvoided = Int(entity.obstaclesAvoided)
    }
}

