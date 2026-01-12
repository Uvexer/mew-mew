import Foundation
import CoreData

@objc(FormulaEntity)
public class FormulaEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FormulaEntity> {
        return NSFetchRequest<FormulaEntity>(entityName: "FormulaEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var formulaText: String
    @NSManaged public var descriptionText: String
    @NSManaged public var variables: String?
    @NSManaged public var isLearned: Bool
    @NSManaged public var orderIndex: Int16
    @NSManaged public var createdAt: Date
    @NSManaged public var lastViewedAt: Date?
    @NSManaged public var category: CategoryEntity?
}

