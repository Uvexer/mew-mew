import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel: TimerViewModel
    @StateObject private var projectsViewModel: ProjectsViewModel
    
    init(coreDataService: CoreDataService) {
        _viewModel = StateObject(wrappedValue: TimerViewModel(coreDataService: coreDataService))
        _projectsViewModel = StateObject(wrappedValue: ProjectsViewModel(coreDataService: coreDataService))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        if let activeEntry = viewModel.activeEntry {
                            ActiveTimerBanner(
                                entry: activeEntry,
                                elapsedTime: viewModel.elapsedTime,
                                onStop: {
                                    Task {
                                        await viewModel.stopTimer()
                                    }
                                }
                            )
                            .frame(height: geometry.size.width > 400 ? 120 : 100)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "timer")
                                    .font(.system(size: geometry.size.width > 400 ? 60 : 48))
                                    .foregroundStyle(.secondary)
                                
                                Text("No active timer")
                                    .font(geometry.size.width > 400 ? .title2 : .title3)
                                    .foregroundStyle(.secondary)
                                
                                Button(action: { viewModel.showingStartTimer = true }) {
                                    Label("Start Timer", systemImage: "play.circle.fill")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: geometry.size.width > 600 ? 300 : .infinity)
                                        .padding()
                                        .background(Color.accentColor)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal, geometry.size.width > 600 ? 0 : 20)
                            }
                            .padding(.vertical, 40)
                        }
                        
                        if !projectsViewModel.projects.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quick Start")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                ForEach(projectsViewModel.projects) { project in
                                    Button(action: {
                                        Task {
                                            await viewModel.startTimer(for: project, notes: nil)
                                        }
                                    }) {
                                        ProjectCard(project: project)
                                    }
                                    .disabled(viewModel.activeEntry != nil)
                                    .opacity(viewModel.activeEntry != nil ? 0.5 : 1.0)
                                }
                            }
                        }
                    }
                    .padding(geometry.size.width > 600 ? 24 : 16)
                }
            }
            .navigationTitle("Timer")
            .sheet(isPresented: $viewModel.showingStartTimer) {
                StartTimerSheet(
                    projects: projectsViewModel.projects,
                    onStart: { project, notes in
                        Task {
                            await viewModel.startTimer(for: project, notes: notes)
                        }
                    }
                )
                .onAppear {
                    projectsViewModel.loadProjects()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct StartTimerSheet: View {
    let projects: [Project]
    let onStart: (Project, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProject: Project?
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if projects.isEmpty {
                        Text("No projects available. Create a project first.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Project", selection: $selectedProject) {
                            Text("Select project")
                                .tag(nil as Project?)
                            
                            ForEach(projects) { project in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: project.colorHex))
                                        .frame(width: 10, height: 10)
                                    Text(project.name)
                                }
                                .tag(project as Project?)
                            }
                        }
                        .labelsHidden()
                    }
                } header: {
                    Text("Project")
                }
                
                Section {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Start Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        if let project = selectedProject {
                            onStart(project, notes.isEmpty ? nil : notes)
                            dismiss()
                        }
                    }
                    .disabled(selectedProject == nil)
                }
            }
        }
    }
}

