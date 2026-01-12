import Foundation
import SwiftUI
import OSLog
import Combine
@MainActor
final class CategoryDetailViewModel: ObservableObject {
    @Published var formulas: [FormulaModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    
    let category: CategoryModel
    private let formulaService: FormulaServiceProtocol
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "timeAppFive", category: "CategoryDetailViewModel")
    
    var filteredFormulas: [FormulaModel] {
        guard !searchQuery.isEmpty else { return formulas }
        return formulas.filter { formula in
            formula.name.localizedCaseInsensitiveContains(searchQuery) ||
            formula.formulaText.localizedCaseInsensitiveContains(searchQuery) ||
            formula.descriptionText.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    var learnedCount: Int {
        formulas.filter { $0.isLearned }.count
    }
    
    var progress: Double {
        guard !formulas.isEmpty else { return 0 }
        return Double(learnedCount) / Double(formulas.count)
    }
    
    init(category: CategoryModel, formulaService: FormulaServiceProtocol) {
        self.category = category
        self.formulaService = formulaService
    }
    
    func loadFormulas() async {
        isLoading = true
        errorMessage = nil
        
        do {
            formulas = try await formulaService.fetchFormulas(for: category.id)
            logger.info("Loaded \(self.formulas.count) formulas for category")
        } catch {
            errorMessage = "Не удалось загрузить формулы"
            logger.error("Failed to load formulas: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func toggleLearnedStatus(for formula: FormulaModel) async {
   
        guard let index = formulas.firstIndex(where: { $0.id == formula.id }) else { return }
        let previous = formulas[index]
        formulas[index] = previous.with(isLearned: !previous.isLearned)

        do {
            try await formulaService.toggleLearnedStatus(formulaId: formula.id)
            logger.info("Toggled learned status")
        } catch {
            formulas[index] = previous
            errorMessage = "Не удалось обновить статус"
            logger.error("Failed to toggle learned status: \(error.localizedDescription)")
        }
    }
    
    func updateLastViewed(for formula: FormulaModel) async {
        do {
            try await formulaService.updateLastViewed(formulaId: formula.id)
        } catch {
            logger.error("Failed to update last viewed: \(error.localizedDescription)")
        }
    }
}

