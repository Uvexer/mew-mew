import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(dataService: DataService) {
        _viewModel = StateObject(wrappedValue: GameViewModel(dataService: dataService))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                
                if !viewModel.isGameActive && !viewModel.isGameOver {
                    startScreen
                } else if viewModel.isGameOver {
                    gameOverScreen
                } else {
                    gameContent
                }
            }
            .onAppear {
                viewModel.setScreenSize(geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                viewModel.setScreenSize(newSize)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isGameActive {
                    Text("Score: \(viewModel.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var startScreen: some View {
        VStack(spacing: 30) {
            Text("✈️")
                .font(.system(size: 80))
            
            Text("Sky Pilot")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Tap to control the plane\nAvoid obstacles")
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("Start Flight")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 60)
                    .background(Color.green)
                    .cornerRadius(15)
            }
        }
    }
    
    private var gameOverScreen: some View {
        VStack(spacing: 25) {
            Text("Flight Ended")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                StatRow(title: "Score", value: "\(viewModel.score)")
                StatRow(title: "Obstacles Avoided", value: "\(viewModel.obstaclesAvoided)")
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.resetGame()
                    viewModel.startGame()
                }) {
                    Text("Fly Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.resetGame()
                    dismiss()
                }) {
                    Text("Exit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    private var gameContent: some View {
        ZStack {
            ForEach(viewModel.obstacles) { obstacle in
                ObstacleView(obstacle: obstacle)
            }
            
            PlaneView()
                .position(
                    x: viewModel.planePosition.x + 30,
                    y: viewModel.planePosition.y + 30
                )
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    viewModel.movePlane(to: value.location)
                }
        )
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .font(.headline)
    }
}

