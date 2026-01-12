import SwiftUI

struct StatisticsCard: View {
    let statistics: ProjectStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(hex: statistics.project.colorHex))
                    .frame(width: 12, height: 12)
                
                Text(statistics.project.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(statistics.totalDuration.formattedDuration)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: statistics.project.colorHex))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Entries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(statistics.entriesCount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

