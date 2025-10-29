import Foundation
import CoreData

extension MomentEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MomentEntity> {
        return NSFetchRequest<MomentEntity>(entityName: "MomentEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var authorID: UUID
    @NSManaged public var photoURL: URL?
    @NSManaged public var voiceURL: URL?
    @NSManaged public var moodEmoji: String?
    @NSManaged public var moodLabel: String?
}

