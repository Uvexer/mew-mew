import Foundation
import SwiftUI
import OSLog
import Combine
import CoreData
@MainActor
final class MainViewModel: ObservableObject {
    @Published var categories: [CategoryModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var selectedTab: Int = 0
    
    private let categoryService: CategoryServiceProtocol
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "timeAppFive", category: "MainViewModel")
    private var cancellables = Set<AnyCancellable>()
    
    var totalFormulas: Int {
        categories.reduce(0) { $0 + $1.formulasCount }
    }
    
    var totalLearned: Int {
        categories.reduce(0) { $0 + $1.learnedCount }
    }
    
    var overallProgress: Double {
        guard totalFormulas > 0 else { return 0 }
        return Double(totalLearned) / Double(totalFormulas)
    }
    
    init(categoryService: CategoryServiceProtocol, context: NSManagedObjectContext) {
        self.categoryService = categoryService

        // Обновляем категории при изменениях в Core Data (например, когда формула отмечена как изученная).
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.refreshCategories() }
            }
            .store(in: &cancellables)
    }
    
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await categoryService.fetchCategories()
            logger.info("Loaded \(self.categories.count) categories")
        } catch {
            errorMessage = "Не удалось загрузить категории"
            logger.error("Failed to load categories: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func refreshCategories() async {
        await loadCategories()
    }
}

