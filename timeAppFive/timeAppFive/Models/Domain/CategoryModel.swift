import Foundation
import SwiftUI

struct CategoryModel: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let iconName: String
    let colorHex: String
    let orderIndex: Int
    var formulasCount: Int
    var learnedCount: Int
    
    var progress: Double {
        guard formulasCount > 0 else { return 0 }
        return Double(learnedCount) / Double(formulasCount)
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    init(id: UUID = UUID(), name: String, iconName: String, colorHex: String, orderIndex: Int, formulasCount: Int = 0, learnedCount: Int = 0) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.orderIndex = orderIndex
        self.formulasCount = formulasCount
        self.learnedCount = learnedCount
    }
    
    init(from entity: CategoryEntity) {
        self.id = entity.id
        self.name = entity.name
        self.iconName = entity.iconName
        self.colorHex = entity.colorHex
        self.orderIndex = Int(entity.orderIndex)
        
        let formulas = entity.formulas as? Set<FormulaEntity> ?? []
        self.formulasCount = formulas.count
        self.learnedCount = formulas.filter { $0.isLearned }.count
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

