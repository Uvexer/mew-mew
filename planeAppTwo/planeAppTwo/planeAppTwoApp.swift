import SwiftUI
import CoreData

@main
struct PlaneAppTwoApp: App {
    private let persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView(dataService: DataService(persistenceController: persistenceController))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
