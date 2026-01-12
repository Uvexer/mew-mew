import SwiftUI

struct ProjectsView: View {
    @StateObject private var viewModel: ProjectsViewModel
    
    init(coreDataService: CoreDataService) {
        _viewModel = StateObject(wrappedValue: ProjectsViewModel(coreDataService: coreDataService))
    }
    
    var body: some View {
        NavigationView {
            projectsContent
                .navigationTitle("Projects")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { viewModel.showingAddProject = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingAddProject) {
                    AddProjectSheet(onSave: { name, color in
                        Task {
                            await viewModel.addProject(name: name, color: color)
                        }
                    })
                }
                .sheet(item: $viewModel.editingProject) { project in
                    EditProjectSheet(
                        project: project,
                        onSave: { name, color in
                            Task {
                                await viewModel.updateProject(project, name: name, color: color)
                            }
                        }
                    )
                }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    private var projectsContent: some View {
        GeometryReader { geometry in
            ScrollView {
                if viewModel.projects.isEmpty {
                    emptyStateView(geometry: geometry)
                } else {
                    projectsList(geometry: geometry)
                }
            }
        }
    }
    
    private func emptyStateView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: geometry.size.width > 400 ? 60 : 48))
                .foregroundStyle(.secondary)
            
            Text("No projects yet")
                .font(geometry.size.width > 400 ? .title2 : .title3)
                .foregroundStyle(.secondary)
            
            Text("Create your first project to start tracking time")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, geometry.size.height * 0.2)
    }
    
    private func projectsList(geometry: GeometryProxy) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.projects) { project in
                ProjectCard(project: project)
                    .contextMenu {
                        Button(action: {
                            handleEditProject(project)
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            Task {
                                await viewModel.deleteProject(project)
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .padding(geometry.size.width > 600 ? 24 : 16)
    }
    
    private func handleEditProject(_ project: Project) {
        let projects = viewModel.coreDataService.fetchProjects()
        if let entity = projects.first(where: { $0.id == project.id }) {
            viewModel.editingProject = entity
        }
    }
}

struct AddProjectSheet: View {
    let onSave: (String, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var selectedColor: String = "#FF6B6B"
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Project name", text: $name)
                } header: {
                    Text("Name")
                }
                
                Section {
                    ColorPicker(selectedColor: $selectedColor)
                        .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, selectedColor)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct EditProjectSheet: View {
    let project: ProjectEntity
    let onSave: (String, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var selectedColor: String
    
    init(project: ProjectEntity, onSave: @escaping (String, String) -> Void) {
        self.project = project
        self.onSave = onSave
        _name = State(initialValue: project.name ?? "")
        _selectedColor = State(initialValue: project.colorHex ?? "#FF6B6B")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Project name", text: $name)
                } header: {
                    Text("Name")
                }
                
                Section {
                    ColorPicker(selectedColor: $selectedColor)
                        .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("Edit Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, selectedColor)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

