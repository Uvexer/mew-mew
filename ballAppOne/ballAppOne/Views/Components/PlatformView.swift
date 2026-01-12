import SwiftUI

struct PlatformView: View {
    let platform: Platform
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: platform.width, height: platform.height)
            .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
            .position(platform.position)
    }
}

