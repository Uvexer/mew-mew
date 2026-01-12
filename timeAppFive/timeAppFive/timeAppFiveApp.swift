import SwiftUI
import OSLog
import CoreData
@main
struct timeAppFiveApp: App {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "timeAppFive", category: "App")
    private let coreDataStack = CoreDataStack.shared
    @State private var hasInitializedData = false
    
    var body: some Scene {
        WindowGroup {
            MainView(
                categoryService: CategoryService(context: coreDataStack.viewContext),
                context: coreDataStack.viewContext
            )
            .environment(\.managedObjectContext, coreDataStack.viewContext)
            .task {
             
                let shouldInitialize: Bool = await MainActor.run {
                    guard !hasInitializedData else { return false }
                    hasInitializedData = true
                    return true
                }
                guard shouldInitialize else { return }
                await initializeData()
            }
        }
    }

    
    @MainActor
    private func initializeData() async {
        logger.info("Initializing application data")
        
        let initService = DataInitializationService(context: coreDataStack.viewContext)
        
        do {
            try await initService.initializeDefaultData()
            logger.info("Data initialization completed")
        } catch {
            logger.error("Failed to initialize data: \(error.localizedDescription)")
        }
    }
}
