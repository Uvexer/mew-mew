import SwiftUI

struct FormulaRowView: View {
    let formula: FormulaModel
    let categoryColor: Color
    let onToggleLearned: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: geometry.size.width * 0.03) {
                Button(action: onToggleLearned) {
                    Image(systemName: formula.isLearned ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: geometry.size.width * 0.06))
                        .foregroundColor(formula.isLearned ? categoryColor : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: geometry.size.height * 0.1) {
                    Text(formula.name)
                        .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(formula.formulaText)
                        .font(.system(size: geometry.size.width * 0.035, design: .monospaced))
                        .foregroundColor(categoryColor)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: geometry.size.width * 0.035))
                    .foregroundColor(.secondary)
            }
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .stroke(formula.isLearned ? categoryColor.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .aspectRatio(5, contentMode: .fit)
    }
}

