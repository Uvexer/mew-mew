import Foundation

enum AnimalCategory: String, CaseIterable, Identifiable {
    case mammal = "Млекопитающие"
    case bird = "Птицы"
    case reptile = "Рептилии"
    case fish = "Рыбы"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .mammal: return "🦁"
        case .bird: return "🦅"
        case .reptile: return "🦎"
        case .fish: return "🐠"
        }
    }
}

struct Animal: Identifiable, Equatable {
    let id: UUID
    let name: String
    let scientificName: String
    let description: String
    let habitat: String
    let lifespan: String
    let fact: String
    let category: AnimalCategory
    let imageName: String
    var isFavorite: Bool
    
    init(from entity: AnimalEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.scientificName = entity.scientificName ?? ""
        self.description = entity.animalDescription ?? ""
        self.habitat = entity.habitat ?? ""
        self.lifespan = entity.lifespan ?? ""
        self.fact = entity.fact ?? ""
        self.category = AnimalCategory(rawValue: entity.category ?? "") ?? .mammal
        self.imageName = entity.imageName ?? ""
        self.isFavorite = entity.isFavorite
    }
}

