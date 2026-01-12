import SwiftUI

struct TimeEntryCard: View {
    let entry: TimeEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color(hex: entry.projectColorHex))
                    .frame(width: 10, height: 10)
                
                Text(entry.projectName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(entry.duration.formattedDuration)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: entry.projectColorHex))
            }
            
            HStack {
                Label(formatTime(entry.startDate), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let endDate = entry.endDate {
                    Text("→")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Label(formatTime(endDate), systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let notes = entry.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

