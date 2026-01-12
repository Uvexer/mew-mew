import Foundation
import CoreData
import OSLog
import Combine

@MainActor
final class TimerViewModel: ObservableObject {
    @Published var activeEntry: TimeEntry?
    @Published var elapsedTime: TimeInterval = 0
    @Published var showingStartTimer = false
    
    private let coreDataService: CoreDataService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "workAppSix", category: "TimerViewModel")
    private var timer: Timer?
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        loadActiveEntry()
        startTimerIfNeeded()
    }
    
    func loadActiveEntry() {
        if let entity = coreDataService.fetchActiveTimeEntry() {
            activeEntry = TimeEntry(from: entity)
            updateElapsedTime()
        } else {
            activeEntry = nil
            elapsedTime = 0
        }
    }
    
    private func startTimerIfNeeded() {
        timer?.invalidate()
        
        if activeEntry != nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateElapsedTime()
            }
        }
    }
    
    private func updateElapsedTime() {
        if let entry = activeEntry {
            elapsedTime = Date().timeIntervalSince(entry.startDate)
        }
    }
    
    func startTimer(for project: Project, notes: String?) async {
        guard let projectEntity = coreDataService.fetchProjects().first(where: { $0.id == project.id }) else { return }
        
        if let currentEntity = coreDataService.fetchActiveTimeEntry() {
            await coreDataService.stopTimeEntry(currentEntity)
        }
        
        let entity = await coreDataService.startTimeEntry(for: projectEntity, notes: notes)
        activeEntry = TimeEntry(from: entity)
        elapsedTime = 0
        startTimerIfNeeded()
        
        logger.info("Timer started for project: \(project.name)")
    }
    
    func stopTimer() async {
        guard let active = activeEntry,
              let entity = coreDataService.fetchActiveTimeEntry() else { return }
        
        await coreDataService.stopTimeEntry(entity)
        activeEntry = nil
        elapsedTime = 0
        timer?.invalidate()
        
        logger.info("Timer stopped")
    }
    
    deinit {
        timer?.invalidate()
    }
}

