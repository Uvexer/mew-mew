

import SwiftUI

@main
struct ballAppOneApp: App {
    let coreDataService = CoreDataService.shared
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environment(\.managedObjectContext, coreDataService.viewContext)
        }
    }
}
