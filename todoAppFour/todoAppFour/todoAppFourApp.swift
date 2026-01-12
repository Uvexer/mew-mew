import SwiftUI

@main
struct todoAppFourApp: App {
    private let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: createViewModel())
        }
    }
    
    private func createViewModel() -> TodoListViewModel {
        let context = coreDataStack.viewContext
        
        let todoService = TodoService(context: context)
        let categoryService = CategoryService(context: context)
        let gameStatsService = GameStatsService(context: context)
        
        return TodoListViewModel(
            todoService: todoService,
            categoryService: categoryService,
            gameStatsService: gameStatsService
        )
    }
}
