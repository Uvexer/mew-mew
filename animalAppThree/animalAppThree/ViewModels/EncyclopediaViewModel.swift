import Foundation
import OSLog
import Combine
@MainActor
final class EncyclopediaViewModel: ObservableObject {
    @Published var animals: [Animal] = []
    @Published var filteredAnimals: [Animal] = []
    @Published var selectedCategory: AnimalCategory?
    @Published var searchText: String = ""
    @Published var showFavoritesOnly: Bool = false
    
    private let animalDataService: AnimalDataService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AnimalApp", category: "Encyclopedia")
    
    init(animalDataService: AnimalDataService) {
        self.animalDataService = animalDataService
    }
    
    func loadAnimals() {
        animals = animalDataService.fetchAllAnimals()
        applyFilters()
        logger.info("Loaded \(self.animals.count) animals")
    }
    
    func toggleFavorite(for animal: Animal) {
        animalDataService.toggleFavorite(for: animal.id)
        loadAnimals()
    }
    
    func selectCategory(_ category: AnimalCategory?) {
        selectedCategory = category
        applyFilters()
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }
    
    func toggleFavoritesFilter() {
        showFavoritesOnly.toggle()
        applyFilters()
    }
    
    private func applyFilters() {
        var result = animals
        
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter { animal in
                animal.name.localizedCaseInsensitiveContains(searchText) ||
                animal.scientificName.localizedCaseInsensitiveContains(searchText) ||
                animal.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredAnimals = result
    }
}

