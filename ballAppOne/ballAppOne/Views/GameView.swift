import SwiftUI
import Combine

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var gameSize: CGSize = .zero
    private let primaryTint = Color(uiColor: .systemTeal)
    
    init() {
        _viewModel = StateObject(wrappedValue: GameViewModel())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    
                    gameArea
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    controlBar
                        .padding()
                }
            }
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView(
                    settings: viewModel.physicsSettings,
                    onSave: { settings in
                        viewModel.updatePhysicsSettings(settings)
                    }
                )
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button {
                    viewModel.showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(primaryTint)
                        .padding(8)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Settings")
            }

            ScoreCardView(
                title: "High Score",
                value: "\(viewModel.highScore)",
                subtitle: "Current: \(viewModel.bounces)"
            )
        }
    }
    
    private var gameArea: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                BallView(ball: viewModel.ball)
                
                PlatformView(platform: viewModel.platform)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        viewModel.movePlatform(to: value.location, bounds: geometry.size)
                    }
            )
            .onReceive(Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()) { _ in
                viewModel.updateGame(bounds: geometry.size)
            }
            .onAppear {
                gameSize = geometry.size
                viewModel.updateLayout(bounds: geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                gameSize = newSize
                viewModel.updateLayout(bounds: newSize)
            }
        }
    }
    
    private var controlBar: some View {
        HStack(spacing: 16) {
            if viewModel.isPlaying {
                Button {
                    viewModel.pauseGame()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryTint)
            } else if viewModel.isPaused {
                Button {
                    viewModel.resumeGame()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryTint)
                
                Button {
                    viewModel.resetGame(bounds: gameSize)
                } label: {
                    Label("New Game", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(primaryTint)
            } else {
                Button {
                    viewModel.startGame(bounds: gameSize)
                } label: {
                    Label("Play", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryTint)
            }
        }
        .controlSize(.large)
    }
}

