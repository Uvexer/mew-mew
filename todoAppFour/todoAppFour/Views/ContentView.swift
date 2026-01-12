import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: TodoListViewModel
    @State private var showingAddTodo = false
    @State private var showingGameStats = false
    
    init(viewModel: TodoListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    mainContent
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingGameStats = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("\(viewModel.gameStats.totalPoints)")
                                .font(.headline)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTodo = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingGameStats) {
                GameStatsView(stats: viewModel.gameStats)
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            filterSection
            categoryFilterSection
            todoList
        }
    }
    
    private var filterSection: some View {
        GeometryReader { geometry in
            HStack(spacing: 8) {
                ForEach(TodoListViewModel.TodoFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedFilter == filter ? .semibold : .regular)
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedFilter == filter ? Color.accentColor : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(height: 48)
        .background(Color(uiColor: .systemBackground))
        .overlay(
            Divider(), alignment: .bottom
        )
    }
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterChip(
                    title: "All",
                    color: .gray,
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    withAnimation {
                        viewModel.selectedCategory = nil
                    }
                }
                
                ForEach(viewModel.categories) { category in
                    CategoryFilterChip(
                        title: category.name,
                        color: category.color,
                        isSelected: viewModel.selectedCategory == category.id
                    ) {
                        withAnimation {
                            viewModel.selectedCategory = category.id
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemBackground))
        .overlay(
            Divider(), alignment: .bottom
        )
    }
    
    private var todoList: some View {
        Group {
            if viewModel.filteredTodos.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.filteredTodos) { todo in
                        TodoRowView(
                            todo: todo,
                            category: viewModel.categories.first { $0.id == todo.categoryId },
                            onToggle: {
                                Task {
                                    await viewModel.toggleCompletion(todo.id)
                                }
                            },
                            onDelete: {
                                Task {
                                    await viewModel.deleteTodo(todo.id)
                                }
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("No tasks")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add a new task to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

