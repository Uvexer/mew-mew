import Foundation

struct PhysicsSettings {
    var gravity: Double
    var bounciness: Double
    var airResistance: Double
    
    static let `default` = PhysicsSettings(
        gravity: 980,
        bounciness: 0.8,
        airResistance: 0.99
    )
    
    init(gravity: Double, bounciness: Double, airResistance: Double) {
        self.gravity = max(0, min(2000, gravity))
        self.bounciness = max(0, min(1, bounciness))
        self.airResistance = max(0.9, min(1, airResistance))
    }
}

