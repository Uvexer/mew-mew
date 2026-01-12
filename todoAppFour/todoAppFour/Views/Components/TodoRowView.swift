import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let category: Category?
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                onToggle()
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(todo.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                    .strikethrough(todo.isCompleted)
                
                HStack(spacing: 8) {
                    if let category = category {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption2)
                            Text(category.name)
                                .font(.caption)
                        }
                        .foregroundStyle(category.color)
                    }
                    
                    priorityBadge
                    
                    if let dueDate = todo.dueDate {
                        dueDateLabel(dueDate)
                    }
                }
            }
            
            Spacer()
            
            Button {
                showingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
    }
    
    private var priorityBadge: some View {
        Text(todo.priority.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundStyle(priorityColor)
            .clipShape(Capsule())
    }
    
    private var priorityColor: Color {
        switch todo.priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    private func dueDateLabel(_ date: Date) -> some View {
        let isOverdue = date < Date() && !todo.isCompleted
        
        return HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption2)
            Text(date, style: .date)
                .font(.caption)
        }
        .foregroundStyle(isOverdue ? .red : .secondary)
    }
}

