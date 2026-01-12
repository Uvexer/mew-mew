import Foundation
import Combine
import CoreGraphics
import OSLog

@MainActor
final class GameViewModel: ObservableObject {
    @Published var planePosition: CGPoint = .zero
    @Published var obstacles: [Obstacle] = []
    @Published var score: Int = 0
    @Published var isGameActive: Bool = false
    @Published var isGameOver: Bool = false
    @Published var obstaclesAvoided: Int = 0
    
    private let dataService: DataService
    private let logger = Logger(subsystem: "com.planeapp", category: "game")
    
    private var gameStartTime: Date?
    private var screenSize: CGSize = .zero
    private var gameTimer: Task<Void, Never>?
    private var obstacleTimer: Task<Void, Never>?
    
    private let planeSize = CGSize(width: 60, height: 60)
    private let obstacleSpeed: Double = 3.0
    private let obstacleSpawnInterval: Double = 1.5
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func setScreenSize(_ size: CGSize) {
        self.screenSize = size
        self.planePosition = CGPoint(x: size.width * 0.2, y: size.height / 2)
    }
    
    func startGame() {
        guard !isGameActive else { return }
        
        isGameActive = true
        isGameOver = false
        score = 0
        obstaclesAvoided = 0
        obstacles.removeAll()
        gameStartTime = Date()
        
        planePosition = CGPoint(x: screenSize.width * 0.2, y: screenSize.height / 2)
        
        logger.info("Game started")
        
        startGameLoop()
        startObstacleSpawning()
    }
    
    func endGame() {
        isGameActive = false
        isGameOver = true
        
        gameTimer?.cancel()
        obstacleTimer?.cancel()
        
        if let startTime = gameStartTime {
            let duration = Int(Date().timeIntervalSince(startTime))
            dataService.saveFlight(score: score, duration: duration, obstaclesAvoided: obstaclesAvoided)
            logger.info("Game ended. Score: \(self.score), Duration: \(duration)s")
        }
    }
    
    func movePlane(to position: CGPoint) {
        guard isGameActive else { return }
        
        let clampedX = min(max(position.x - planeSize.width / 2, 0), screenSize.width - planeSize.width)
        let clampedY = min(max(position.y - planeSize.height / 2, 0), screenSize.height - planeSize.height)
        
        planePosition = CGPoint(x: clampedX, y: clampedY)
    }
    
    func resetGame() {
        isGameOver = false
        obstacles.removeAll()
    }
    
    private func startGameLoop() {
        gameTimer = Task {
            while isGameActive && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 16_666_667)
                
                updateObstacles()
                checkCollisions()
                
                score += 1
            }
        }
    }
    
    private func startObstacleSpawning() {
        obstacleTimer = Task {
            while isGameActive && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(obstacleSpawnInterval * 1_000_000_000))
                
                spawnObstacle()
            }
        }
    }
    
    private func spawnObstacle() {
        guard screenSize.width > 0 && screenSize.height > 0 else { return }
        
        let obstacleHeight = CGFloat.random(in: 40...80)
        let obstacleWidth = CGFloat.random(in: 60...100)
        let yPosition = CGFloat.random(in: 0...(screenSize.height - obstacleHeight))
        
        let obstacle = Obstacle(
            position: CGPoint(x: screenSize.width, y: yPosition),
            size: CGSize(width: obstacleWidth, height: obstacleHeight),
            type: Bool.random() ? .cloud : .bird
        )
        
        obstacles.append(obstacle)
    }
    
    private func updateObstacles() {
        for index in obstacles.indices.reversed() {
            obstacles[index].position.x -= obstacleSpeed
            
            if obstacles[index].position.x + obstacles[index].size.width < 0 {
                obstacles.remove(at: index)
                obstaclesAvoided += 1
            }
        }
    }
    
    private func checkCollisions() {
        let planeFrame = CGRect(
            origin: planePosition,
            size: planeSize
        )
        
        for obstacle in obstacles {
            if planeFrame.intersects(obstacle.frame) {
                endGame()
                return
            }
        }
    }
}

