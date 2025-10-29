import Foundation
import CoreData

protocol MomentRepositoryProtocol {
    func fetchMoments(type: Moment.MomentType?) async throws -> [Moment]
    func createMoment(_ moment: Moment) async throws
    func deleteMoment(id: UUID) async throws
}

class MomentRepository: MomentRepositoryProtocol {
    private let persistenceController: PersistenceController
    private let cloudKitService: CloudKitServiceProtocol
    
    init(persistenceController: PersistenceController, cloudKitService: CloudKitServiceProtocol) {
        self.persistenceController = persistenceController
        self.cloudKitService = cloudKitService
    }
    
    func fetchMoments(type: Moment.MomentType? = nil) async throws -> [Moment] {
        let context = persistenceController.container.viewContext
        
        return try await context.perform {
            let request = MomentEntity.fetchRequest()
            if let type = type {
                request.predicate = NSPredicate(format: "type == %@", type.rawValue)
            }
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let entities = try request.execute()
            return entities.map { entity in
                Moment(
                    id: entity.id,
                    type: Moment.MomentType(rawValue: entity.type) ?? .note,
                    content: entity.content,
                    createdAt: entity.createdAt,
                    authorID: entity.authorID,
                    photoURL: entity.photoURL,
                    voiceURL: entity.voiceURL,
                    mood: entity.moodEmoji.map { 
                        Moment.Mood(emoji: $0, label: entity.moodLabel ?? "") 
                    }
                )
            }
        }
    }
    
    func createMoment(_ moment: Moment) async throws {
        let context = persistenceController.container.viewContext
        
        try await context.perform {
            let entity = MomentEntity(context: context)
            entity.id = moment.id
            entity.type = moment.type.rawValue
            entity.content = moment.content
            entity.createdAt = moment.createdAt
            entity.authorID = moment.authorID
            entity.photoURL = moment.photoURL
            entity.voiceURL = moment.voiceURL
            entity.moodEmoji = moment.mood?.emoji
            entity.moodLabel = moment.mood?.label
            
            try context.save()
        }
        
        try await cloudKitService.syncMoment(moment)
    }
    
    func deleteMoment(id: UUID) async throws {
        let context = persistenceController.container.viewContext
        
        try await context.perform {
            let request = MomentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            if let entity = try request.execute().first {
                context.delete(entity)
                try context.save()
            }
        }
        
        try await cloudKitService.deleteMoment(id: id)
    }
}

class InMemoryMomentRepository: MomentRepositoryProtocol {
    private var moments: [Moment] = []
    
    func fetchMoments(type: Moment.MomentType? = nil) async throws -> [Moment] {
        if let type = type {
            return moments.filter { $0.type == type }
        }
        return moments
    }
    
    func createMoment(_ moment: Moment) async throws {
        moments.append(moment)
    }
    
    func deleteMoment(id: UUID) async throws {
        moments.removeAll { $0.id == id }
    }
}

