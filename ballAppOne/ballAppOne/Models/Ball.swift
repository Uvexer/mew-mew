import Foundation
import CoreGraphics

struct Ball: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    var velocity: CGVector
    let radius: CGFloat
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        position: CGPoint,
        velocity: CGVector = .zero,
        radius: CGFloat = 20,
        isActive: Bool = true
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.radius = radius
        self.isActive = isActive
    }
    
    static func == (lhs: Ball, rhs: Ball) -> Bool {
        lhs.id == rhs.id &&
        lhs.position.x == rhs.position.x &&
        lhs.position.y == rhs.position.y &&
        lhs.velocity.dx == rhs.velocity.dx &&
        lhs.velocity.dy == rhs.velocity.dy
    }
}

