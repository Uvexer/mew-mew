import Foundation
import CoreGraphics
import SwiftUI
import Combine
import OSLog

@MainActor
final class GameViewModel: ObservableObject {
    @Published var ball: Ball
    @Published var platform: Platform
    @Published var bounces: Int = 0
    @Published var highScore: Int = 0
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var physicsSettings: PhysicsSettings = .default
    @Published var showSettings: Bool = false
    
    private let physicsService: PhysicsService
    private let coreDataService: CoreDataService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ballapp", category: "Game")
    
    private var lastUpdateTime: Date?
    private var gameSession: GameSessionEntity?
    private var shouldUpdatePlatform: Bool = false
    private var targetPlatformX: CGFloat = 0
    private var platformBounds: CGSize = .zero
    private var lastKnownGameBounds: CGSize = .zero
    
    init(
        physicsService: PhysicsService = PhysicsService(),
        coreDataService: CoreDataService = .shared
    ) {
        self.physicsService = physicsService
        self.coreDataService = coreDataService
        
        self.ball = Ball(position: CGPoint(x: 200, y: 100), radius: 25)
        self.platform = Platform(position: CGPoint(x: 200, y: 300), width: 120, height: 20)
        
        loadGameState()
        
        logger.debug("GameViewModel initialized | ball: (\(self.ball.position.x), \(self.ball.position.y)) | platform: (\(self.platform.position.x), \(self.platform.position.y))")
    }
    
    func updateLayout(bounds: CGSize) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        lastKnownGameBounds = bounds
        platformBounds = bounds

        let y = platformY(in: bounds)
        let halfWidth = platform.width / 2
        let clampedX = max(halfWidth, min(bounds.width - halfWidth, platform.position.x))
        platform.position = CGPoint(x: clampedX, y: y)

        if !isPlaying && !isPaused {
            ball.position = CGPoint(x: bounds.width / 2, y: max(ball.radius + 16, y - 140))
            ball.velocity = .zero
        }
    }

    func startGame(bounds: CGSize) {
        bounces = 0
        isPlaying = true
        isPaused = false
        lastUpdateTime = Date()
        
        lastKnownGameBounds = bounds
        platformBounds = bounds
        let centerX = bounds.width / 2
        let platformY = platformY(in: bounds)
        
        ball = Ball(position: CGPoint(x: centerX, y: 100), radius: 25)
        platform = Platform(position: CGPoint(x: centerX, y: platformY), width: 120, height: 20)
        
        logger.info("Game started | ball: \(centerX), 100 | platform: \(centerX), \(platformY) | bounds: \(bounds.width)x\(bounds.height)")
    }
    
    func resumeGame() {
        isPlaying = true
        isPaused = false
        lastUpdateTime = Date()
        logger.info("Game resumed")
    }
    
    func pauseGame() {
        isPlaying = false
        isPaused = true
        lastUpdateTime = nil
        saveGameState()
        logger.info("Game paused")
    }
    
    func resetGame(bounds: CGSize) {
        startGame(bounds: bounds)
        logger.info("Game reset")
    }
    
    func updateGame(bounds: CGSize) {
        if lastKnownGameBounds.width != bounds.width || lastKnownGameBounds.height != bounds.height {
            updateLayout(bounds: bounds)
        }

        if shouldUpdatePlatform {
            updatePlatformPosition()
        }
        
        guard isPlaying else { return }
        
        let now = Date()
        guard let lastTime = lastUpdateTime else {
            lastUpdateTime = now
            return
        }
        
        let deltaTime = min(now.timeIntervalSince(lastTime), 1.0 / 30.0)
        lastUpdateTime = now
        
        physicsService.updateBall(
            &ball,
            settings: physicsSettings,
            bounds: bounds,
            deltaTime: deltaTime
        )
        
        if physicsService.handlePlatformCollision(
            &ball,
            platform: platform,
            bounciness: physicsSettings.bounciness
        ) {
            bounces += 1
            if bounces > highScore {
                highScore = bounces
                logger.info("New high score: \(self.highScore)")
            }
        }
        
        if ball.position.y - ball.radius > bounds.height {
            isPlaying = false
            isPaused = false
            lastUpdateTime = nil
            saveGameState()
            logger.info("Game over - ball hit bottom at y=\(self.ball.position.y)")
        }
    }
    
    private func updatePlatformPosition() {
        let halfWidth = platform.width / 2
        let clampedX = max(halfWidth, min(platformBounds.width - halfWidth, targetPlatformX))
        platform.position.x = clampedX
        shouldUpdatePlatform = false
    }
    
    func movePlatform(to position: CGPoint, bounds: CGSize) {
        targetPlatformX = position.x
        platformBounds = bounds
        shouldUpdatePlatform = true
    }
    
    private func platformY(in bounds: CGSize) -> CGFloat {
        let margin: CGFloat = 24
        return max(platform.height / 2 + margin, bounds.height - platform.height / 2 - margin)
    }
    
    func updatePhysicsSettings(_ settings: PhysicsSettings) {
        physicsSettings = settings
        saveGameState()
        logger.debug("Physics settings updated")
    }
    
    private func loadGameState() {
        guard let session = coreDataService.fetchGameSession() else {
            logger.info("No saved game state found")
            return
        }
        
        gameSession = session
        bounces = Int(session.bounces)
        highScore = Int(session.highScore)
        physicsSettings = PhysicsSettings(
            gravity: session.gravity,
            bounciness: session.bounciness,
            airResistance: session.airResistance
        )
        
        logger.info("Game state loaded")
    }
    
    private func saveGameState() {
        if let session = gameSession {
            coreDataService.updateGameSession(
                session,
                bounces: Int32(bounces),
                gravity: physicsSettings.gravity,
                bounciness: physicsSettings.bounciness,
                airResistance: physicsSettings.airResistance,
                highScore: Int32(highScore)
            )
        } else {
            gameSession = coreDataService.createGameSession(
                bounces: Int32(bounces),
                gravity: physicsSettings.gravity,
                bounciness: physicsSettings.bounciness,
                airResistance: physicsSettings.airResistance,
                highScore: Int32(highScore)
            )
        }
    }
}

