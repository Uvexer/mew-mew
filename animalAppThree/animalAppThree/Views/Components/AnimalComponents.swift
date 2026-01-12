import SwiftUI

struct AnimalCard: View {
    let animal: Animal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                animalImage
                
                if animal.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(animal.name)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(animal.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var animalImage: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: gradientColors(for: animal.category),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                if let uiImage = UIImage(named: animal.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Text(animal.category.icon)
                        .font(.system(size: 60))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width * 0.75)
            .clipped()
            .cornerRadius(12, corners: [.topLeft, .topRight])
        }
        .aspectRatio(4/3, contentMode: .fit)
    }
    
    private func gradientColors(for category: AnimalCategory) -> [Color] {
        switch category {
        case .mammal: return [.blue, .cyan]
        case .bird: return [.orange, .yellow]
        case .reptile: return [.green, .mint]
        case .fish: return [.blue, .purple]
        }
    }
}

struct AnimalDetailView: View {
    let animal: Animal
    let onFavoriteToggle: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        animalImage(width: geometry.size.width)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            headerSection
                            
                            Divider()
                            
                            infoSection
                            
                            Divider()
                            
                            factSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(animal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onFavoriteToggle()
                    } label: {
                        Image(systemName: animal.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(animal.isFavorite ? .red : .primary)
                    }
                }
            }
        }
    }
    
    private func animalImage(width: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: gradientColors(for: animal.category),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            if let uiImage = UIImage(named: animal.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Text(animal.category.icon)
                    .font(.system(size: 100))
            }
        }
        .frame(width: width, height: width * 0.6)
        .clipped()
    }
    
    private func gradientColors(for category: AnimalCategory) -> [Color] {
        switch category {
        case .mammal: return [.blue, .cyan]
        case .bird: return [.orange, .yellow]
        case .reptile: return [.green, .mint]
        case .fish: return [.blue, .purple]
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(animal.category.icon)
                    .font(.title)
                
                Text(animal.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(animal.scientificName)
                .font(.title3)
                .italic()
                .foregroundColor(.secondary)
            
            Text(animal.description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRow(icon: "map.fill", title: "Среда обитания", value: animal.habitat)
            InfoRow(icon: "clock.fill", title: "Продолжительность жизни", value: animal.lifespan)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var factSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Интересный факт", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundColor(.orange)
            
            Text(animal.fact)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(value)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(icon)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

