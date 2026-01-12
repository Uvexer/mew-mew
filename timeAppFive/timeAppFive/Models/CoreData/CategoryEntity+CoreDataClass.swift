import Foundation
import CoreData

@objc(CategoryEntity)
public class CategoryEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var iconName: String
    @NSManaged public var colorHex: String
    @NSManaged public var orderIndex: Int16
    @NSManaged public var formulas: NSSet?
}

extension CategoryEntity {
    @objc(addFormulasObject:)
    @NSManaged public func addToFormulas(_ value: FormulaEntity)

    @objc(removeFormulasObject:)
    @NSManaged public func removeFromFormulas(_ value: FormulaEntity)

    @objc(addFormulas:)
    @NSManaged public func addToFormulas(_ values: NSSet)

    @objc(removeFormulas:)
    @NSManaged public func removeFromFormulas(_ values: NSSet)
}

