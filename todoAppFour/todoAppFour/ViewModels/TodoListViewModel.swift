import Foundation
import os.log
import Combine

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var categories: [Category] = []
    @Published var gameStats: GameStats = GameStats()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: TodoFilter = .all
    @Published var selectedCategory: UUID?
    
    private let todoService: TodoService
    private let categoryService: CategoryService
    private let gameStatsService: GameStatsService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "todoAppFour", category: "TodoListViewModel")
    
    enum TodoFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
    }
    
    var filteredTodos: [TodoItem] {
        var result = todos
        
        switch selectedFilter {
        case .all:
            break
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        }
        
        if let categoryId = selectedCategory {
            result = result.filter { $0.categoryId == categoryId }
        }
        
        return result
    }
    
    init(todoService: TodoService, categoryService: CategoryService, gameStatsService: GameStatsService) {
        self.todoService = todoService
        self.categoryService = categoryService
        self.gameStatsService = gameStatsService
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let todosTask = todoService.fetchAll()
            async let categoriesTask = categoryService.fetchAll()
            async let statsTask = gameStatsService.fetchStats()
            
            let (fetchedTodos, fetchedCategories, fetchedStats) = try await (todosTask, categoriesTask, statsTask)
            
            todos = fetchedTodos
            categories = fetchedCategories
            gameStats = fetchedStats
            
            if categories.isEmpty {
                try await categoryService.initializeDefaultCategories()
                categories = try await categoryService.fetchAll()
            }
            
            logger.info("Data loaded successfully")
        } catch {
            logger.error("Failed to load data: \(error.localizedDescription)")
            errorMessage = "Failed to load data. Please try again."
        }
        
        isLoading = false
    }
    
    func addTodo(title: String, notes: String?, priority: TodoPriority, dueDate: Date?, categoryId: UUID?) async {
        let todo = TodoItem(
            title: title,
            notes: notes,
            priority: priority,
            dueDate: dueDate,
            categoryId: categoryId
        )
        
        do {
            try await todoService.create(todo)
            todos.insert(todo, at: 0)
            logger.info("Todo added: \(title)")
        } catch {
            logger.error("Failed to add todo: \(error.localizedDescription)")
            errorMessage = "Failed to add task. Please try again."
        }
    }
    
    func updateTodo(_ todo: TodoItem) async {
        do {
            try await todoService.update(todo)
            if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                todos[index] = todo
            }
            logger.info("Todo updated: \(todo.title)")
        } catch {
            logger.error("Failed to update todo: \(error.localizedDescription)")
            errorMessage = "Failed to update task. Please try again."
        }
    }
    
    func deleteTodo(_ id: UUID) async {
        do {
            try await todoService.delete(id)
            todos.removeAll { $0.id == id }
            logger.info("Todo deleted: \(id)")
        } catch {
            logger.error("Failed to delete todo: \(error.localizedDescription)")
            errorMessage = "Failed to delete task. Please try again."
        }
    }
    
    func toggleCompletion(_ id: UUID) async {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }
        
        var todo = todos[index]
        let wasCompleted = todo.isCompleted
        
        todo.isCompleted.toggle()
        todo.completedAt = todo.isCompleted ? Date() : nil
        
        do {
            try await todoService.update(todo)
            todos[index] = todo
            
            if !wasCompleted && todo.isCompleted {
                let points = todo.priority.points
                try await gameStatsService.addPoints(points)
                gameStats = try await gameStatsService.fetchStats()
                logger.info("Todo completed with \(points) points")
            }
        } catch {
            logger.error("Failed to toggle completion: \(error.localizedDescription)")
            errorMessage = "Failed to update task. Please try again."
        }
    }
}

