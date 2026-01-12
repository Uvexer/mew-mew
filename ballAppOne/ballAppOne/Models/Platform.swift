import Foundation
import CoreGraphics

struct Platform: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    let width: CGFloat
    let height: CGFloat
    
    init(
        id: UUID = UUID(),
        position: CGPoint,
        width: CGFloat = 100,
        height: CGFloat = 20
    ) {
        self.id = id
        self.position = position
        self.width = width
        self.height = height
    }
    
    static func == (lhs: Platform, rhs: Platform) -> Bool {
        lhs.id == rhs.id &&
        lhs.position.x == rhs.position.x &&
        lhs.position.y == rhs.position.y
    }
    
    func intersects(with ball: Ball) -> Bool {
        let ballLeft = ball.position.x - ball.radius
        let ballRight = ball.position.x + ball.radius
        let ballTop = ball.position.y - ball.radius
        let ballBottom = ball.position.y + ball.radius
        
        let platformLeft = position.x - width / 2
        let platformRight = position.x + width / 2
        let platformTop = position.y - height / 2
        let platformBottom = position.y + height / 2
        
        return ballRight > platformLeft &&
               ballLeft < platformRight &&
               ballBottom > platformTop &&
               ballTop < platformBottom
    }
}

