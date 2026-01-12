import Foundation
import CoreData

@objc(GameSessionEntity)
public class GameSessionEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var bounces: Int32
    @NSManaged public var gravity: Double
    @NSManaged public var bounciness: Double
    @NSManaged public var airResistance: Double
    @NSManaged public var highScore: Int32
    @NSManaged public var lastPlayed: Date
}

extension GameSessionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameSessionEntity> {
        return NSFetchRequest<GameSessionEntity>(entityName: "GameSessionEntity")
    }
}

