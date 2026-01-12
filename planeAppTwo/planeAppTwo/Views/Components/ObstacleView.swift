import SwiftUI

struct ObstacleView: View {
    let obstacle: Obstacle
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(obstacleColor)
                .frame(width: obstacle.size.width, height: obstacle.size.height)
            
            Text(obstacleEmoji)
                .font(.system(size: obstacle.size.height * 0.6))
        }
        .position(
            x: obstacle.position.x + obstacle.size.width / 2,
            y: obstacle.position.y + obstacle.size.height / 2
        )
        .shadow(color: .black.opacity(0.2), radius: 3, x: 1, y: 1)
    }
    
    private var obstacleColor: Color {
        switch obstacle.type {
        case .cloud:
            return Color.white.opacity(0.7)
        case .bird:
            return Color.orange.opacity(0.3)
        }
    }
    
    private var obstacleEmoji: String {
        switch obstacle.type {
        case .cloud:
            return "☁️"
        case .bird:
            return "🦅"
        }
    }
}

