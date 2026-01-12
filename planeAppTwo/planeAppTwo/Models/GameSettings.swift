import Foundation

struct GameSettings {
    let difficulty: Int
    let soundEnabled: Bool
    let highScore: Int
    let totalFlights: Int
    
    init(from entity: GameSettingsEntity) {
        self.difficulty = Int(entity.difficulty)
        self.soundEnabled = entity.soundEnabled
        self.highScore = Int(entity.highScore)
        self.totalFlights = Int(entity.totalFlights)
    }
}

