import Foundation
import SwiftUI

class DataExportService {
    private let momentRepository: MomentRepositoryProtocol

    init(momentRepository: MomentRepositoryProtocol) {
        self.momentRepository = momentRepository
    }

    func exportMomentsAsJSON() async throws -> URL {
        let moments = try await momentRepository.fetchMoments(type: nil)

        let exportData = moments.map { moment -> [String: Any] in
            var dict: [String: Any] = [
                "id": moment.id.uuidString,
                "type": moment.type.rawValue,
                "content": moment.content,
                "createdAt": ISO8601DateFormatter().string(from: moment.createdAt),
                "authorID": moment.authorID.uuidString
            ]
            if let mood = moment.mood {
                dict["mood"] = ["emoji": mood.emoji, "label": mood.label]
            }
            return dict
        }

        let wrapper: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "momentCount": moments.count,
            "moments": exportData
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: wrapper, options: [.prettyPrinted, .sortedKeys])

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "redii_export_\(dateFormatter.string(from: Date())).json"
        let fileURL = tempDir.appendingPathComponent(fileName)

        try jsonData.write(to: fileURL)
        return fileURL
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }
}
