import SwiftUI
import OSLog

@main
struct animalAppThreeApp: App {
    private let persistenceController = PersistenceController.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AnimalApp", category: "App")
    
    init() {
        let animalDataService = AnimalDataService(context: persistenceController.viewContext)
        animalDataService.seedDataIfNeeded()
        logger.info("Application started")
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(context: persistenceController.viewContext)
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
