import SwiftUI

struct Obstacle: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    let size: CGSize
    let type: ObstacleType
    
    init(position: CGPoint, size: CGSize, type: ObstacleType = .cloud) {
        self.id = UUID()
        self.position = position
        self.size = size
        self.type = type
    }
    
    var frame: CGRect {
        CGRect(origin: position, size: size)
    }
}

enum ObstacleType {
    case cloud
    case bird
}

