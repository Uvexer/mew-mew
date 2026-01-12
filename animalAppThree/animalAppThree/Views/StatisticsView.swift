import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        if let progress = viewModel.userProgress {
                            overallStatsSection(progress: progress, geometry: geometry)
                        }
                        
                        recentGamesSection(geometry: geometry)
                    }
                    .padding()
                }
            }
            .navigationTitle("Статистика")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.loadRecentScores()
            viewModel.loadUserProgress()
        }
    }
    
    private func overallStatsSection(progress: UserProgress, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Общая статистика")
                .font(.title2)
                .fontWeight(.bold)
            
            statsGrid(progress: progress, geometry: geometry)
        }
    }
    
    private func statsGrid(progress: UserProgress, geometry: GeometryProxy) -> some View {
        let columns = adaptiveColumns(for: geometry.size.width)
        
        return LazyVGrid(columns: columns, spacing: 16) {
            StatCard(
                icon: "gamecontroller.fill",
                title: "Игр сыграно",
                value: "\(progress.gamesPlayed)",
                color: .blue
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                title: "Правильных ответов",
                value: "\(progress.totalCorrectAnswers)",
                color: .green
            )
            
            StatCard(
                icon: "percent",
                title: "Средний результат",
                value: String(format: "%.0f%%", progress.averageScore),
                color: .orange
            )
        }
    }
    
    private func recentGamesSection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Последние игры")
                .font(.title2)
                .fontWeight(.bold)
            
            if viewModel.recentScores.isEmpty {
                emptyStateView
            } else {
                recentGamesList
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет сыгранных игр")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Сыграйте в викторину, чтобы увидеть результаты здесь")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var recentGamesList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.recentScores) { score in
                GameScoreRow(score: score)
            }
        }
    }
    
    private func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let minColumnWidth: CGFloat = 150
        let spacing: CGFloat = 16
        let horizontalPadding: CGFloat = 32
        let availableWidth = width - horizontalPadding
        let columnCount = max(1, Int(availableWidth / (minColumnWidth + spacing)))
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct GameScoreRow: View {
    let score: GameScore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(score.correctAnswers) из \(score.totalQuestions)")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Text(String(format: "%.0f%%", score.percentage))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(percentageColor)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: score.date)
    }
    
    private var percentageColor: Color {
        if score.percentage >= 80 {
            return .green
        } else if score.percentage >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

