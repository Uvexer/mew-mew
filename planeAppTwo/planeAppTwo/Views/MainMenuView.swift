import SwiftUI

struct MainMenuView: View {
    @StateObject private var statsViewModel: StatsViewModel
    @State private var showingGame = false
    @State private var showingStats = false
    
    private let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
        _statsViewModel = StateObject(wrappedValue: StatsViewModel(dataService: dataService))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    backgroundGradient
                    
                    VStack(spacing: geometry.size.height * 0.05) {
                        Spacer()
                        
                        headerSection
                        
                        if let settings = statsViewModel.settings {
                            highScoreSection(settings: settings)
                        }
                        
                        menuButtons
                        
                        Spacer()
                    }
                    .padding(.horizontal, geometry.size.width * 0.1)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                statsViewModel.loadData()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.4, blue: 0.8),
                Color(red: 0.2, green: 0.6, blue: 0.9),
                Color(red: 0.4, green: 0.7, blue: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Text("✈️")
                .font(.system(size: 100))
                .shadow(color: .white.opacity(0.5), radius: 10)
            
            Text("Sky Pilot")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
    
    private func highScoreSection(settings: GameSettings) -> some View {
        VStack(spacing: 10) {
            Text("High Score")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            Text("\(settings.highScore)")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 3)
            
            Text("Total Flights: \(settings.totalFlights)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.2))
                .shadow(color: .black.opacity(0.2), radius: 8)
        )
    }
    
    private var menuButtons: some View {
        VStack(spacing: 20) {
            NavigationLink(destination: GameView(dataService: dataService)) {
                MenuButton(title: "Start Flight", icon: "airplane.departure", color: Color(red: 0.3, green: 0.6, blue: 0.85))
            }
            
            NavigationLink(destination: StatsView(dataService: dataService)) {
                MenuButton(title: "Flight History", icon: "chart.bar.fill", color: Color(red: 0.4, green: 0.65, blue: 0.9))
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color)
                .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 4)
        )
    }
}

