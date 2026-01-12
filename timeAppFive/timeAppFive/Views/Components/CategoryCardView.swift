import SwiftUI

struct CategoryCardView: View {
    let category: CategoryModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.2))
                            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                        
                        Image(systemName: category.iconName)
                            .font(.system(size: geometry.size.width * 0.07))
                            .foregroundColor(category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("\(category.formulasCount) формул")
                            .font(.system(size: geometry.size.width * 0.035))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(category.progress * 100))%")
                            .font(.system(size: geometry.size.width * 0.045, weight: .bold))
                            .foregroundColor(category.color)
                        
                        Text("\(category.learnedCount)/\(category.formulasCount)")
                            .font(.system(size: geometry.size.width * 0.03))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(geometry.size.width * 0.04)
                
                GeometryReader { progressGeometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(category.color)
                            .frame(width: progressGeometry.size.width * category.progress, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .stroke(category.color.opacity(0.3), lineWidth: 1)
            )
        }
        .aspectRatio(3.5, contentMode: .fit)
    }
}

