import Foundation
import CoreGraphics
import OSLog

final class PhysicsService {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ballapp", category: "Physics")
    
    func updateBall(
        _ ball: inout Ball,
        settings: PhysicsSettings,
        bounds: CGSize,
        deltaTime: TimeInterval
    ) {
        let dt = CGFloat(deltaTime)
        
        ball.velocity.dy += CGFloat(settings.gravity) * dt
        
        ball.velocity.dx *= CGFloat(settings.airResistance)
        ball.velocity.dy *= CGFloat(settings.airResistance)
        
        ball.position.x += ball.velocity.dx * dt
        ball.position.y += ball.velocity.dy * dt
        
        handleBoundaryCollision(&ball, bounds: bounds, bounciness: CGFloat(settings.bounciness))
    }
    
    func handlePlatformCollision(
        _ ball: inout Ball,
        platform: Platform,
        bounciness: Double
    ) -> Bool {
        guard platform.intersects(with: ball) else { return false }
        
        let ballBottom = ball.position.y + ball.radius
        let platformTop = platform.position.y - platform.height / 2
        
        if ball.velocity.dy > 0 && ballBottom >= platformTop {
            ball.position.y = platformTop - ball.radius - 2
            
            let minBounceVelocity: CGFloat = 300
            let bounceVelocity = max(minBounceVelocity, abs(ball.velocity.dy) * CGFloat(bounciness))
            ball.velocity.dy = -bounceVelocity
            
            let offsetFromCenter = ball.position.x - platform.position.x
            let maxOffset = platform.width / 2
            let normalizedOffset = offsetFromCenter / maxOffset
            ball.velocity.dx += normalizedOffset * 200
            
            logger.debug("Ball bounced on platform")
            return true
        }
        
        return false
    }
    
    private func handleBoundaryCollision(
        _ ball: inout Ball,
        bounds: CGSize,
        bounciness: CGFloat
    ) {
        if ball.position.x - ball.radius <= 0 {
            ball.position.x = ball.radius
            ball.velocity.dx = abs(ball.velocity.dx) * bounciness
        } else if ball.position.x + ball.radius >= bounds.width {
            ball.position.x = bounds.width - ball.radius
            ball.velocity.dx = -abs(ball.velocity.dx) * bounciness
        }
        
        if ball.position.y - ball.radius <= 0 {
            ball.position.y = ball.radius
            ball.velocity.dy = abs(ball.velocity.dy) * bounciness
        }
    }
}

