import SwiftUI

struct FormulaDetailView: View {
    let formula: FormulaModel
    let categoryColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: geometry.size.height * 0.03) {
                    // Вместо navigationTitle (который часто обрезается "...") показываем
                    // полный заголовок внутри контента, чтобы он переносился на строки.
                    Text(formula.name)
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    FormulaCardView(
                        formula: formula,
                        categoryColor: categoryColor,
                        size: geometry.size
                    )
                    .padding(.horizontal)
                    
                    DescriptionCardView(
                        description: formula.descriptionText,
                        categoryColor: categoryColor,
                        size: geometry.size
                    )
                    .padding(.horizontal)
                    
                    if !formula.variables.isEmpty {
                        VariablesCardView(
                            variables: formula.variables,
                            categoryColor: categoryColor,
                            size: geometry.size
                        )
                        .padding(.horizontal)
                    }
                    
                    StatusCardView(
                        formula: formula,
                        categoryColor: categoryColor,
                        size: geometry.size
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FormulaCardView: View {
    let formula: FormulaModel
    let categoryColor: Color
    let size: CGSize
    
    var body: some View {
        VStack(spacing: size.height * 0.02) {
            Text("Формула")
                .font(.system(size: size.width * 0.04, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(formula.formulaText)
                .font(.system(size: size.width * 0.07, weight: .semibold, design: .monospaced))
                .foregroundColor(categoryColor)
                .padding(size.width * 0.04)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: size.width * 0.03)
                        .fill(categoryColor.opacity(0.1))
                )
        }
        .padding(size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: size.width * 0.04)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

struct DescriptionCardView: View {
    let description: String
    let categoryColor: Color
    let size: CGSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: size.height * 0.02) {
            Text("Описание")
                .font(.system(size: size.width * 0.04, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(description)
                .font(.system(size: size.width * 0.04))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: size.width * 0.04)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

struct VariablesCardView: View {
    let variables: [String]
    let categoryColor: Color
    let size: CGSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: size.height * 0.02) {
            Text("Переменные")
                .font(.system(size: size.width * 0.04, weight: .medium))
                .foregroundColor(.secondary)
            
            FlowLayout(spacing: size.width * 0.02) {
                ForEach(variables, id: \.self) { variable in
                    Text(variable)
                        .font(.system(size: size.width * 0.035, design: .monospaced))
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, size.width * 0.03)
                        .padding(.vertical, size.height * 0.01)
                        .background(
                            Capsule()
                                .fill(categoryColor.opacity(0.15))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: size.width * 0.04)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

struct StatusCardView: View {
    let formula: FormulaModel
    let categoryColor: Color
    let size: CGSize
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: size.height * 0.02) {
            HStack {
                Image(systemName: formula.isLearned ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: size.width * 0.05))
                    .foregroundColor(formula.isLearned ? .green : .gray)
                
                Text(formula.isLearned ? "Изучено" : "Не изучено")
                    .font(.system(size: size.width * 0.04, weight: .medium))
                    .foregroundColor(formula.isLearned ? .green : .secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: size.height * 0.01) {
                HStack {
                    Text("Создано:")
                        .font(.system(size: size.width * 0.035))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: formula.createdAt))
                        .font(.system(size: size.width * 0.035))
                        .foregroundColor(.primary)
                }
                
                if let lastViewed = formula.lastViewedAt {
                    HStack {
                        Text("Просмотрено:")
                            .font(.system(size: size.width * 0.035))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(dateFormatter.string(from: lastViewed))
                            .font(.system(size: size.width * 0.035))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: size.width * 0.04)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

