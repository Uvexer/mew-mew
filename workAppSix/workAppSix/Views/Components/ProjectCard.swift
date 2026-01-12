import SwiftUI

struct ProjectCard: View {
    let project: Project
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: project.colorHex))
                .frame(width: 12, height: 12)
            
            Text(project.name)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(hex: project.colorHex).opacity(0.1))
        .cornerRadius(12)
    }
}

