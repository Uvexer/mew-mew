import SwiftUI

struct MainTabView: View {
    let coreDataService: CoreDataService
    
    var body: some View {
        TabView {
            TimerView(coreDataService: coreDataService)
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
            
            EntriesView(coreDataService: coreDataService)
                .tabItem {
                    Label("Entries", systemImage: "clock")
                }
            
            ProjectsView(coreDataService: coreDataService)
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
            
            StatisticsView(coreDataService: coreDataService)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
        }
    }
}

