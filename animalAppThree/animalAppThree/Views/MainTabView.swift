import SwiftUI
import CoreData
struct MainTabView: View {
    @StateObject private var encyclopediaViewModel: EncyclopediaViewModel
    @StateObject private var gameViewModel: GameViewModel
    
    init(context: NSManagedObjectContext) {
        let animalDataService = AnimalDataService(context: context)
        let gameService = GameService(context: context)
        
        _encyclopediaViewModel = StateObject(wrappedValue: EncyclopediaViewModel(animalDataService: animalDataService))
        _gameViewModel = StateObject(wrappedValue: GameViewModel(animalDataService: animalDataService, gameService: gameService))
    }
    
    var body: some View {
        TabView {
            EncyclopediaView(viewModel: encyclopediaViewModel)
                .tabItem {
                    Label("Энциклопедия", systemImage: "book.fill")
                }
            
            GameView(viewModel: gameViewModel)
                .tabItem {
                    Label("Игра", systemImage: "gamecontroller.fill")
                }
            
            StatisticsView(viewModel: gameViewModel)
                .tabItem {
                    Label("Статистика", systemImage: "chart.bar.fill")
                }
        }
        .onAppear {
            encyclopediaViewModel.loadAnimals()
            gameViewModel.loadRecentScores()
            gameViewModel.loadUserProgress()
        }
    }
}

