import Foundation
import CoreData
import OSLog
import Combine
@MainActor
final class EntriesViewModel: ObservableObject {
    @Published var entries: [TimeEntry] = []
    @Published var selectedDate = Date() {
        didSet {
            loadEntries()
        }
    }
    @Published var editingEntry: TimeEntryEntity?
    @Published var statistics: [ProjectStatistics] = []
    
    let coreDataService: CoreDataService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "workAppSix", category: "EntriesViewModel")
    private var cancellables = Set<AnyCancellable>()
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        loadEntries()
        calculateStatistics()
        observeChanges()
    }
    
    func loadEntries() {
        let startOfDay = selectedDate.startOfDay
        let endOfDay = selectedDate.endOfDay
        
        let entities = coreDataService.fetchTimeEntries(from: startOfDay, to: endOfDay)
        entries = entities.map { TimeEntry(from: $0) }
        
        logger.info("Loaded \(self.entries.count) entries for selected date")
    }
    
    func calculateStatistics() {
        let allEntries = coreDataService.fetchTimeEntries()
        let projects = coreDataService.fetchProjects()
        
        statistics = projects.compactMap { projectEntity in
            let project = Project(from: projectEntity)
            let projectEntries = allEntries.filter { $0.project?.id == project.id }
            
            guard !projectEntries.isEmpty else { return nil }
            
            let totalDuration = projectEntries.reduce(0.0) { result, entry in
                let endDate = entry.endDate ?? Date()
                return result + endDate.timeIntervalSince(entry.startDate ?? Date())
            }
            
            return ProjectStatistics(
                project: project,
                totalDuration: totalDuration,
                entriesCount: projectEntries.count
            )
        }.sorted { $0.totalDuration > $1.totalDuration }
        
        logger.info("Calculated statistics for \(self.statistics.count) projects")
    }

    private func observeChanges() {
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextObjectsDidChange,
            object: coreDataService.viewContext
        )
        .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.loadEntries()
            self?.calculateStatistics()
        }
        .store(in: &cancellables)
    }
    
    func deleteEntry(_ entry: TimeEntry) async {
        guard let entity = coreDataService.fetchTimeEntries().first(where: { $0.id == entry.id }) else { return }
        
        await coreDataService.deleteTimeEntry(entity)
        loadEntries()
        calculateStatistics()
    }
    
    func updateEntry(_ entryEntity: TimeEntryEntity, startDate: Date, endDate: Date?, notes: String?) async {
        await coreDataService.updateTimeEntry(entryEntity, startDate: startDate, endDate: endDate, notes: notes)
        loadEntries()
        calculateStatistics()
    }
}

