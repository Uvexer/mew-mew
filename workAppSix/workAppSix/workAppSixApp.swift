import SwiftUI

@main
struct workAppSixApp: App {
    private let coreDataService = CoreDataService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(coreDataService: coreDataService)
                .environment(\.managedObjectContext, coreDataService.viewContext)
        }
    }
}
