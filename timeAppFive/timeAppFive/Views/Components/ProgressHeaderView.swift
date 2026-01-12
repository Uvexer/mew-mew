import SwiftUI

struct ProgressHeaderView: View {
    let totalFormulas: Int
    let learnedFormulas: Int
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.1) {
                VStack(spacing: geometry.size.height * 0.05) {
                    Text("Общий прогресс")
                        .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: geometry.size.width * 0.02)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: geometry.size.width * 0.02, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 2) {
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                            
                            Text("\(learnedFormulas)/\(totalFormulas)")
                                .font(.system(size: geometry.size.width * 0.035))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: geometry.size.height * 0.6, height: geometry.size.height * 0.6)
                }
                
                HStack(spacing: geometry.size.width * 0.05) {
                    StatBadgeView(
                        title: "Изучено",
                        value: "\(learnedFormulas)",
                        color: .green,
                        size: geometry.size
                    )
                    
                    StatBadgeView(
                        title: "Осталось",
                        value: "\(totalFormulas - learnedFormulas)",
                        color: .orange,
                        size: geometry.size
                    )
                    
                    StatBadgeView(
                        title: "Всего",
                        value: "\(totalFormulas)",
                        color: .blue,
                        size: geometry.size
                    )
                }
            }
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
        .aspectRatio(1.3, contentMode: .fit)
    }
}

struct StatBadgeView: View {
    let title: String
    let value: String
    let color: Color
    let size: CGSize
    
    var body: some View {
        VStack(spacing: size.height * 0.05) {
            Text(value)
                .font(.system(size: size.width * 0.055, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: size.width * 0.03))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, size.height * 0.08)
        .background(
            RoundedRectangle(cornerRadius: size.width * 0.025)
                .fill(color.opacity(0.1))
        )
    }
}

