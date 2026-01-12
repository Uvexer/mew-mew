import SwiftUI

struct ActiveTimerBanner: View {
    let entry: TimeEntry
    let elapsedTime: TimeInterval
    let onStop: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: entry.projectColorHex))
                                .frame(width: 10, height: 10)
                            
                            Text(entry.projectName)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        
                        Text(elapsedTime.formattedDuration)
                            .font(.system(size: geometry.size.width > 400 ? 32 : 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: entry.projectColorHex))
                            .monospacedDigit()
                    }
                    
                    Spacer()
                    
                    Button(action: onStop) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color(hex: entry.projectColorHex))
                    }
                }
                .padding(geometry.size.width > 400 ? 20 : 16)
                .background(Color(hex: entry.projectColorHex).opacity(0.1))
                .cornerRadius(16)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

