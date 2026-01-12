import SwiftUI

struct PlaneView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 60)
            
            Text("✈️")
                .font(.system(size: 40))
                .rotationEffect(.degrees(-10))
        }
        .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
    }
}

