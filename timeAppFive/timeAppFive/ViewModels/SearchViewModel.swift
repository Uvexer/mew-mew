import Foundation
import SwiftUI
import OSLog
import Combine
import CoreData
@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [FormulaModel] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?
    
    private let formulaService: FormulaServiceProtocol
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "timeAppFive", category: "SearchViewModel")
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(formulaService: FormulaServiceProtocol, context: NSManagedObjectContext) {
        self.formulaService = formulaService

        // Если пользователь держит экран поиска открытым, а данные меняются в Core Data,
        // переисполняем поиск, чтобы чекмарки/статусы обновлялись без перезахода.
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                guard !self.searchQuery.isEmpty else { return }
                self.search()
            }
            .store(in: &cancellables)
    }
    
    func search() {
        searchTask?.cancel()
        
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                
                guard !Task.isCancelled else { return }
                
                isSearching = true
                errorMessage = nil
                
                let results = try await formulaService.searchFormulas(query: searchQuery)
                
                guard !Task.isCancelled else { return }
                
                searchResults = results
                logger.info("Search completed with \(results.count) results")
                
                isSearching = false
            } catch {
                guard !Task.isCancelled else { return }
                
                errorMessage = "Ошибка поиска"
                logger.error("Search failed: \(error.localizedDescription)")
                isSearching = false
            }
        }
    }
    
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        searchTask?.cancel()
    }
}

