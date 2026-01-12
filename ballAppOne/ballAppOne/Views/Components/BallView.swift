import SwiftUI

struct BallView: View {
    let ball: Ball
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: ball.radius * 2, height: ball.radius * 2)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            .position(ball.position)
    }
}

