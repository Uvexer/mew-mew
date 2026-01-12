import SwiftUI

struct ColorPickerButton: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Circle()
            .fill(Color(hex: color))
            .frame(width: 44, height: 44)
            .overlay(
                Circle()
                    .stroke(Color.primary, lineWidth: isSelected ? 3 : 0)
                    .padding(isSelected ? -4 : 0)
            )
            .onTapGesture {
                action()
            }
    }
}

struct ColorPicker: View {
    @Binding var selectedColor: String
    
    private let colors = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A",
        "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2",
        "#52B788", "#F4A261", "#E76F51", "#2A9D8F"
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(colors, id: \.self) { color in
                ColorPickerButton(
                    color: color,
                    isSelected: selectedColor == color,
                    action: { 
                        selectedColor = color
                    }
                )
            }
        }
        .padding(.horizontal, 4)
    }
}

