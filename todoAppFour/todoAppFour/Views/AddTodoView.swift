import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TodoListViewModel
    
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedPriority: TodoPriority = .medium
    @State private var selectedCategoryId: UUID?
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task title", text: $title)
                        .font(.body)
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .font(.body)
                        .lineLimit(3...6)
                }
                
                Section {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TodoPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Picker("Category", selection: $selectedCategoryId) {
                        Text("None").tag(nil as UUID?)
                        ForEach(viewModel.categories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundStyle(category.color)
                                Text(category.name)
                            }
                            .tag(category.id as UUID?)
                        }
                    }
                }
                
                Section {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(
                            "Due date",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTodo()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTodo() {
        Task {
            await viewModel.addTodo(
                title: title,
                notes: notes.isEmpty ? nil : notes,
                priority: selectedPriority,
                dueDate: hasDueDate ? dueDate : nil,
                categoryId: selectedCategoryId
            )
            dismiss()
        }
    }
}

