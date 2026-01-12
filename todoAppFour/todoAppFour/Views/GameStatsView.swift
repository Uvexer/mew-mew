import SwiftUI

struct GameStatsView: View {
    @Environment(\.dismiss) private var dismiss
    let stats: GameStats
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    levelSection
                    
                    statsGrid
                    
                    streakSection
                }
                .padding()
            }
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var levelSection: some View {
        VStack(spacing: 12) {
            Text("Level \(stats.level)")
                .font(.system(size: 48, weight: .bold))
            
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 12)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * stats.progressToNextLevel,
                                height: 12
                            )
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("\(stats.totalPoints % stats.pointsToNextLevel) / \(stats.pointsToNextLevel) XP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("Next level: \(stats.level + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                icon: "star.fill",
                title: "Total Points",
                value: "\(stats.totalPoints)",
                color: .yellow
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                title: "Completed",
                value: "\(stats.completedTasksCount)",
                color: .green
            )
            
            StatCard(
                icon: "flame.fill",
                title: "Current Streak",
                value: "\(stats.currentStreak)",
                color: .orange
            )
            
            StatCard(
                icon: "trophy.fill",
                title: "Best Streak",
                value: "\(stats.bestStreak)",
                color: .purple
            )
        }
    }
    
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keep it up!")
                .font(.headline)
            
            Text("Complete tasks daily to maintain your streak and earn more points.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

