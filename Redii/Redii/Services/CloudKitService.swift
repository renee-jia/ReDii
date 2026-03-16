import Foundation
import CloudKit

protocol CloudKitServiceProtocol {
    func syncMoment(_ moment: Moment) async throws
    func deleteMoment(id: UUID) async throws
    func fetchMoments() async throws -> [Moment]
    func fetchMessages() async throws -> [ChatMessage]
    func sendMessage(_ message: ChatMessage) async throws
    func updateMessageReaction(messageID: UUID, reaction: String) async throws
    func pairWithCode(_ code: String) async throws -> User?
    func registerUser(_ user: User) async throws
    func subscribeToChanges() async throws
}

class CloudKitService: CloudKitServiceProtocol {
    private let container: CKContainer
    private let privateDB: CKDatabase
    private let publicDB: CKDatabase
    private var isCloudKitAvailable: Bool = false

    static let momentRecordType = "Moment"
    static let messageRecordType = "ChatMessage"
    static let userRecordType = "RediiUser"
    static let pairRecordType = "PairLink"

    init() {
        self.container = CKContainer.default()
        self.privateDB = container.privateCloudDatabase
        self.publicDB = container.publicCloudDatabase

        Task {
            await checkCloudKitAvailability()
        }
    }

    private func checkCloudKitAvailability() async {
        do {
            let status = try await container.accountStatus()
            isCloudKitAvailable = (status == .available)
        } catch {
            isCloudKitAvailable = false
        }
    }

    // MARK: - Moments

    func syncMoment(_ moment: Moment) async throws {
        guard isCloudKitAvailable else { throw CloudKitError.unavailable }

        let record = CKRecord(recordType: Self.momentRecordType, recordID: CKRecord.ID(recordName: moment.id.uuidString))
        record["type"] = moment.type.rawValue
        record["content"] = moment.content
        record["createdAt"] = moment.createdAt
        record["authorID"] = moment.authorID.uuidString

        if let photoURL = moment.photoURL {
            let asset = CKAsset(fileURL: photoURL)
            record["photo"] = asset
        }

        if let voiceURL = moment.voiceURL {
            let asset = CKAsset(fileURL: voiceURL)
            record["voice"] = asset
        }

        if let mood = moment.mood {
            record["moodEmoji"] = mood.emoji
            record["moodLabel"] = mood.label
        }

        try await privateDB.save(record)
    }

    func deleteMoment(id: UUID) async throws {
        guard isCloudKitAvailable else { throw CloudKitError.unavailable }

        let recordID = CKRecord.ID(recordName: id.uuidString)
        try await privateDB.deleteRecord(withID: recordID)
    }

    func fetchMoments() async throws -> [Moment] {
        guard isCloudKitAvailable else { throw CloudKitError.unavailable }

        let query = CKQuery(recordType: Self.momentRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let (results, _) = try await privateDB.records(matching: query)

        return results.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return momentFromRecord(record)
        }
    }

    private func momentFromRecord(_ record: CKRecord) -> Moment? {
        guard let typeRaw = record["type"] as? String,
              let type = Moment.MomentType(rawValue: typeRaw),
              let content = record["content"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let authorIDStr = record["authorID"] as? String,
              let authorID = UUID(uuidString: authorIDStr) else {
            return nil
        }

        let photoURL = (record["photo"] as? CKAsset)?.fileURL
        let voiceURL = (record["voice"] as? CKAsset)?.fileURL

        var mood: Moment.Mood?
        if let emoji = record["moodEmoji"] as? String {
            mood = Moment.Mood(emoji: emoji, label: record["moodLabel"] as? String ?? "")
        }

        return Moment(
            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
            type: type,
            content: content,
            createdAt: createdAt,
            authorID: authorID,
            photoURL: photoURL,
            voiceURL: voiceURL,
            mood: mood
        )
    }

    // MARK: - Messages

    func fetchMessages() async throws -> [ChatMessage] {
        guard isCloudKitAvailable else { throw CloudKitError.unavailable }

        let query = CKQuery(recordType: Self.messageRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        let (results, _) = try await privateDB.records(matching: query)

        return results.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return messageFromRecord(record)
        }
    }

    func sendMessage(_ message: ChatMessage) async throws {
        guard isCloudKitAvailable else { throw CloudKitError.unavailable }

        let record = CKRecord(recordType: Self.messageRecordType, recordID: CKRecord.ID(recordName: message.id.uuidString))
        record["text"] = message.text
        record["senderID"] = message.senderID.uuidString
        record["timestamp"] = message.timestamp
        record["reaction"] = message.reaction

        try await privateDB.save(record)
    }

    func updateMessageReaction(messageID: UUID, reaction: String) async throws {
        guard isCloudKitAvailable else { throw CloudKitError.unavailable }

        let recordID = CKRecord.ID(recordName: messageID.uuidString)
        let record = try await privateDB.record(for: recordID)
        record["reaction"] = reaction
        try await privateDB.save(record)
    }

    private func messageFromRecord(_ record: CKRecord) -> ChatMessage? {
        guard let text = record["text"] as? String,
              let senderIDStr = record["senderID"] as? String,
              let senderID = UUID(uuidString: senderIDStr),
              let timestamp = record["timestamp"] as? Date else {
            return nil
        }

        return ChatMessage(
            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
            text: text,
            senderID: senderID,
            timestamp: timestamp,
            reaction: record["reaction"] as? String
        )
    }

    // MARK: - Pairing

    func registerUser(_ user: User) async throws {
        guard isCloudKitAvailable else { throw CloudKitError.unavailable }

        let record = CKRecord(recordType: Self.userRecordType, recordID: CKRecord.ID(recordName: user.id.uuidString))
        record["nickname"] = user.nickname
        record["pairCode"] = user.pairCode
        record["isPaired"] = user.isPaired
        record["createdAt"] = user.createdAt

        try await publicDB.save(record)
    }

    func pairWithCode(_ code: String) async throws -> User? {
        guard isCloudKitAvailable else { throw CloudKitError.unavailable }

        let predicate = NSPredicate(format: "pairCode == %@", code)
        let query = CKQuery(recordType: Self.userRecordType, predicate: predicate)

        let (results, _) = try await publicDB.records(matching: query)

        guard let (_, result) = results.first,
              let record = try? result.get() else {
            throw CloudKitError.pairingFailed
        }

        guard let nickname = record["nickname"] as? String else {
            throw CloudKitError.pairingFailed
        }

        let partnerID = UUID(uuidString: record.recordID.recordName) ?? UUID()

        // Create a pair link in shared database
        let pairRecord = CKRecord(recordType: Self.pairRecordType)
        pairRecord["userID1"] = partnerID.uuidString
        pairRecord["pairedAt"] = Date()
        try await publicDB.save(pairRecord)

        return User(
            id: partnerID,
            nickname: nickname,
            pairCode: code,
            anniversaryDate: Date(),
            isPaired: true,
            createdAt: record["createdAt"] as? Date ?? Date()
        )
    }

    // MARK: - Subscriptions

    func subscribeToChanges() async throws {
        guard isCloudKitAvailable else { return }

        let momentSub = CKQuerySubscription(
            recordType: Self.momentRecordType,
            predicate: NSPredicate(value: true),
            subscriptionID: "moment-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let notifInfo = CKSubscription.NotificationInfo()
        notifInfo.shouldSendContentAvailable = true
        momentSub.notificationInfo = notifInfo

        let messageSub = CKQuerySubscription(
            recordType: Self.messageRecordType,
            predicate: NSPredicate(value: true),
            subscriptionID: "message-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )
        messageSub.notificationInfo = notifInfo

        try await privateDB.save(momentSub)
        try await privateDB.save(messageSub)
    }
}

enum CloudKitError: LocalizedError {
    case unavailable
    case pairingFailed
    case recordNotFound

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "iCloud is not available. Please sign into iCloud in Settings."
        case .pairingFailed:
            return "Could not find a partner with that code. Please check and try again."
        case .recordNotFound:
            return "The requested record was not found."
        }
    }
}
