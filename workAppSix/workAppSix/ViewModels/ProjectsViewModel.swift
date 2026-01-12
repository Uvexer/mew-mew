import Foundation
import CoreData
import OSLog
import Combine

@MainActor
final class ProjectsViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var showingAddProject = false
    @Published var editingProject: ProjectEntity?
    
    let coreDataService: CoreDataService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "workAppSix", category: "ProjectsViewModel")
    private var cancellables = Set<AnyCancellable>()
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        loadProjects()
        observeChanges()
    }
    
    func loadProjects() {
        let entities = coreDataService.fetchProjects()
        projects = entities.map { Project(from: $0) }
        logger.info("Loaded \(self.projects.count) projects")
    }

    private func observeChanges() {
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextObjectsDidChange,
            object: coreDataService.viewContext
        )
        .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.loadProjects()
        }
        .store(in: &cancellables)
    }
    
    func addProject(name: String, color: String) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        _ = await coreDataService.createProject(name: name, colorHex: color)
        loadProjects()
    }
    
    func updateProject(_ projectEntity: ProjectEntity, name: String, color: String) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        await coreDataService.updateProject(projectEntity, name: name, colorHex: color)
        loadProjects()
    }
    
    func deleteProject(_ project: Project) async {
        guard let entity = coreDataService.fetchProjects().first(where: { $0.id == project.id }) else { return }
        
        await coreDataService.deleteProject(entity)
        loadProjects()
    }
}

